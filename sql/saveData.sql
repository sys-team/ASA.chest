create or replace procedure ch.saveData(
    @attributes integer default 0
)
begin

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


    -- attribute
    if @attributes = 1 then
        insert into ch.attribute on existing update with auto name
        select (select a.id
                  from ch.attribute a join ch.entity e on a.parent = e.id
                 where e.xid = #attribute.parentXid
                   and a.name = #attribute.name) as id,
               name,
               dataType,
               value,
               xmlData,
               (select id
                  from ch.entity
                 where xid = #attribute.parentXid) as parent
          from #attribute;
    end if;

    -- rel
    insert into ch.relationship on existing update with auto name
    select (select id
              from ch.relationship
             where parentXid = #rel.parentXid
               and childXid = #rel.childXid) as [id],
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
     where #rel.parentXid is not null
       and #rel.childXid is not null
       and parent is not null
       and child is not null
       and ch.entityWriteable(#rel.name, @UOAuthRoles) = 1
    ;

    -- delete rel
    delete from ch.relationship
    where parentXid in (select xid from #entity where type = 'd')
      and not exists (
        select *
        from #rel
        where parentXid = ch.relationship.parentXid
            and childXid = ch.relationship.childXid
    );

end
;
