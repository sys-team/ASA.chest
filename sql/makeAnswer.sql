create or replace function ch.makeAnswer()
returns xml
begin
    declare @result xml;
    
    set @result = (select xmlagg(xmlelement('d', xmlattributes(name as "name", upper(uuidtostr(xid)) as "xid"),
                                               if name is not null and xid is not null then 'ok' else 'error' endif))
                     from #entity);    
    
    return @result;

end
;