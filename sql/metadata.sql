create or replace function ch.metadata(
    @entityList STRING default null
)
returns xml
begin
    declare @result xml;
    declare @properties xml;
    declare @roles xml;
    declare @computes xml;

    for lloop as ccur cursor for
    select c_entity
      from openstring(value @entityList)
           with(c_entity STRING)
           option(delimited by '~' row delimited by ',') as e
    do
    
        set @properties = (select xmlagg(xmlelement(p.type, xmlattributes(p.name as "name", ep.initial as "initial")))
                             from ch.entityProperty ep join ch.property p on ep.property = p.name
                            where ep.entity = c_entity);
                        
        set @roles = (select xmlagg(xmlelement(name, xmlattributes(actor as "actor")))
                        from ch.entityRole
                       where entity = c_entity);
                       
        set @computes = (select xmlagg(xmlelement(name, xmlattributes(expression as "expression")))
                           from ch.entityCompute
                          where entity = c_entity);          
    
        set @result = xmlconcat(@result,
                                xmlelement('entity', xmlattributes(c_entity as name), 
                                    if @properties is not null then xmlelement('properties', @properties) else null endif,
                                    if @roles is not null then xmlelement('roles', @roles) else null endif,
                                    if @computes is not null then xmlelement('computes', @computes) else null endif
                                ));
    
    end for;

    return @result;

end
;
