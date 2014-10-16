create or replace procedure ch.triggerEvent(
    @code STRING default null
) begin
    declare @sql long varchar;

    for lloop as global_events cursor for 
    select event_name as c_name
        from sys.sysevent
        where event_name like '%chestDataPersist'
            and enabled = 'Y'
    do
        set @sql  ='trigger event ' + c_name;
        execute immediate @sql;
    end for;
    
    begin
        
        DECLARE no_entity EXCEPTION FOR SQLSTATE '42W33';
        
        for lloop as entity_events cursor for 
        select
                ev.event_name as event_name,
                en.name as entity_name,
                list (en.xid) as entity_xids
            from sys.sysevent ev join #entity en
                on ev.event_name like en.name+'%chestEntityPersist'
            where ev.enabled = 'Y'
            group by event_name, entity_name
        do
            set @sql = string (
                'trigger event [', event_name, ']',
                ' ( ',
                    '"entity_xids" = ''', entity_xids, '''',
                    ',"auth_token" = ''', isnull (@code, 'null'), '''',
                ' )'
            );
            message 'ch.triggerEvent:', @sql to client;
            execute immediate @sql;
        end for;
        
    exception when no_entity then
        message 'ch.triggerEvent:', 'No #entity ' to client ;
        
    end;

end;