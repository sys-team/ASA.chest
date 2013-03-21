create or replace procedure ch.fillEntityProperty(
    @entity long varchar default null
)
begin

    for lloop as ccur cursor for
    select distinct
           name as c_name
      from ch.entity
     where name = @entity
        or @entity is null
    do
        --message 'ch.fillEntityProperty c_name = ', c_name;
        insert into ch.entityProperty with auto name
        select distinct
               c_name as entity,
               t.property
          from ch.entity e outer apply (select property
                                          from openxml(e.xmlData, '/*:d/*')
                                              with(property long varchar '@name')) as t
         where e.name = c_name
           and t.property is not null
           and not exists (select *
                             from ch.entityProperty
                            where entity = c_name
                              and property = t.property);
    
    end for;

end
;