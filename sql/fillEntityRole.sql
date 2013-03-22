create or replace procedure ch.fillEntityRole(
    @parent long varchar default null,
    @child long varchar default null
)
begin

    insert into ch.entityRole(actor, entity, name)
    select distinct
           c.name as actor,
           p.name as entity,
           (select name
              from openxml(r.xmlData,'/d')
                   with(name long varchar '@name')) as roleName
      from ch.relationship r join ch.entity c on r.child = c.id
                             join ch.entity p on r.parent = p.id
     where (p.name = @parent
        or @parent is null)
       and (c.name = @child
        or @child is null)
       and not exists(select *
                        from ch.entityRole
                       where actor = c.name
                         and entity = p.name
                         and name = roleName);


end
;