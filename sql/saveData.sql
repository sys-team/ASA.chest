create or replace procedure ch.saveData(
    @attributes integer default 0,
    @code long varchar default util.HTTPVariableOrHeader (),
    @logXid GUID default null
)
begin

    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #0'
        debug only
    ;

    update ch.log set
        processing = 'saveData'
    where xid = @logXid;
    
    -- entity
    insert into ch.entity on existing update with auto name
    select (select id
              from ch.entity
             where xid = #entity.xid) as id,
           name,
           code,
           if type = 'd' then
                #entity.xmlData
           else
                ch.mergeXml(#entity.xmlData, (select xmlData from ch.entity where xid = #entity.xid))
           endif as xmlData,
           xid
      from #entity
     where xid is not null
       and name is not null
       and ch.entityWriteable(name, @UOAuthRoles) = 1
    ;

    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #1'
        debug only
    ;

    update ch.log set
        processing = 'saveData:inserted'
    where xid = @logXid;


    delete from ch.relationship
    where parentXid in (
        select xid from #entity where type = 'd'
    );

    update ch.log set
        processing = 'saveData:relationship:delete'
    where xid = @logXid;


    merge into ch.relationship r using with auto name (
        select
            (select id
              from ch.entity
             where xid = #rel.parentXid) as [parent],
            (select id
              from ch.entity
             where xid = #rel.childXid) as [child],
            #rel.parentXid,
            #rel.childXid,
            #rel.xmlData,
            #rel.name as [role]
        from #rel
        where child is not null and parent is not null
    ) as t on t.parentXid = r.parentXid and t.childXid = r.childXid
    when not matched
        then insert
    when matched
        then update
    ;

    update ch.log set
        processing = 'saveData:relationship:merge'
    where xid = @logXid;


end;
