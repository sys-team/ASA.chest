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
    
        insert into ch.property with auto name
        select distinct
               property as name,
               type
          from ch.entity e outer apply (select property,
                                               type
                                          from openxml(e.xmlData, '/*:d/*')
                                               with(property long varchar '@name', type long varchar '@mp:localname')
                                         where type not in ('d')) as t
         where e.name = c_name
           and t.property is not null
           and not exists (select *
                             from ch.property
                            where name = t.property);
        
        insert into ch.entityProperty with auto name
        select distinct
               c_name as entity,
               t.property
          from ch.entity e outer apply (select property,
                                               type
                                          from openxml(e.xmlData, '/*:d/*')
                                               with(property long varchar '@name', type long varchar '@mp:localname')
                                         where type not in ('d')) as t
         where e.name = c_name
           and t.property is not null
           and not exists (select *
                             from ch.entityProperty
                            where entity = c_name
                              and property = t.property);
    
    end for;

end
;