create or replace procedure ch.saveData()
begin
    
    -- entity
    insert into ch.entity on existing update with auto name
    select (select id
              from ch.entity
             where xid = #entity.xid) as id,
           name,
           xmlData,
           xid
      from #entity
     where xid is not null
       and name is not null
       and ch.entityWriteable(name, @UOAuthRoles) = 1;
       
    -- rel
    insert into ch.relationship on existing update with auto name
    select (select id
              from ch.relationship
             where parentXid = #rel.parentXid
               and childXid = #rel.childXid) as id,
           (select id
              from ch.entity
             where xid = #rel.parentXid) as parent,
           (select id
              from ch.entity
             where xid = #rel.childXid) as child,
           parentXid,
           childXid,
           xmlData
      from #rel
     where parentXid is not null
       and childXid is not null
       and ch.entityWriteable(name, @UOAuthRoles) = 1;

    -- delete rel
    delete from ch.relationship
    where parentXid in (select xid from #entity)
      and not exists (select *
                        from #rel
                       where parentXid = ch.relationship.parentXid
                         and childXid = ch.relationship.childXid);

end
;