create or replace function ch.processEmptyRequest()
returns xml
begin
    declare @result xml;
    
    set @result = (select top 1
                          xmlData
                     from ch.entity
                    where name = 'STGTSettings'
                    order by id desc);
    
    return @result;
end
;