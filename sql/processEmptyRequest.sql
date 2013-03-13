create or replace function ch.processEmptyRequest()
returns xml
begin

    declare @result xml;
    
    set @result = (select top 1 xmlelement('d'
        , xmlattributes ('STGTSettings' as "name")
        , xmlconcat(
            
            (select xmlagg(
                    xmldatum
                )
                from openxml(xmlData,'*/*') with (
                    name varchar(32) '@name'
                    , xmldatum xml '@mp:xmltext'
                ) where name not in (
                    'ts'
                )
            ) 
            , xmlelement(
                'date'
                , xmlattributes ('ts' as "name")
                , left(current utc timestamp, 19) + ' +0000'
            )
            
        )) as xmlData
        
        from ch.entity
        where name = 'STGTSettings'
        order by id
    );
    
    return @result;
    
end;