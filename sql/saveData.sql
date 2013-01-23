create or replace procedure ch.saveData()
begin
    
    -- entity
    insert into ch.entity with auto name
    select name,
           xmlData,
           xid
      from #entity
     where not exists (select *
                         from ch.entity
                        where xid = #entity.xid)
       and xid is not null
       and name is not null;
       
    -- rel
    insert into ch.relationship with auto name
    select (select id
              from ch.entity
             where xid = #rel.parentXid) as parent,
           (select id
              from ch.entity
             where xid = #rel.xid) as child
      from #rel
     where parent is not null
       and child is not null;

end
;