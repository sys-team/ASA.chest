create or replace procedure ch.triggerEventsByName(
    @name STRING
) begin

    declare @sql long varchar;

    for lloop as entity_events cursor for
    select
            ev.event_name as event_name
        from sys.sysevent ev
        where ev.enabled = 'Y'
            and ev.event_name like @name+'%chestEntityPersist'
        group by event_name
    do
        set @sql = string (
            'trigger event [', event_name, '];'
        );
        message 'ch.triggerEventsByName: ', @sql;
        execute immediate @sql;
    end for;

end;
