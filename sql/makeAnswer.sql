create or replace function ch.makeAnswer()
returns xml
begin
    declare @result xml;
    
    set @result = (select xmlagg(xmlelement('d', xmlattributes(name as "name", upper(uuidtostr(xid)) as "xid"),
                                                if ch.entityWriteable(name, @UOAuthRoles) = 1 then
                                                    if name is not null and xid is not null then 'ok' else 'error' endif
                                                else
                                                    'permission denied'
                                                endif))
                     from #entity);    
    
    return @result;

end
;