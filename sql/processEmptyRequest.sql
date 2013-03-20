create or replace function ch.processEmptyRequest()
returns xml
begin

    declare @result xml;
    
    set @result = xmlelement('d'
        , xmlattributes ('STGTSettings' as "name")
        , xmlconcat(
            
            (select top 1 (
                select xmlagg(xmldatum)
                    from openxml(xmlData,'*/*') with (
                        name varchar(32) '@name'
                        , xmldatum xml '@mp:xmltext'
                    ) where name not in (
                        'ts', 'distanceFilter', 'requiredAccuracy', 'timeFilter', 'syncInterval', 'fetchLimit', 'syncServerURI'
                    )
                    
                ) as xmlData
                
                from ch.entity
                where name = 'STGTSettings'
                order by id
            )
            
            , xmlelement(
                'date'
                , xmlattributes ('ts' as "name")
                , left(current utc timestamp, 19) + ' +0000'
            )
            , xmlelement(
                'double'
                , xmlattributes ('distanceFilter' as "name")
                , 20
            )
            , xmlelement(
                'double'
                , xmlattributes ('timeFilter' as "name")
                , 15
            )
            , xmlelement(
                'double'
                , xmlattributes ('requiredAccuracy' as "name")
                , 20
            )
            , xmlelement(
                'double'
                , xmlattributes ('fetchLimit' as "name")
                , 20
            )
            , xmlelement(
                'double'
                , xmlattributes ('syncInterval' as "name")
                , 240
            )
            , xmlelement(
                'string'
                , xmlattributes ('syncServerURI' as "name")
                , 'https://system.unact.ru/asa/?_host=asa0&_svc=chest'
            )
    ));
    
    return @result;
    
end;