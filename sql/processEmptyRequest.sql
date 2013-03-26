create or replace function ch.processEmptyRequest(
    @code long varchar default isnull(nullif(replace(http_header('Authorization'), 'Bearer ', ''),''), http_variable('authorization:'))
)
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
                        'ts'
                        , 'distanceFilter', 'requiredAccuracy', 'timeFilter'
                        , 'syncInterval', 'fetchLimit', 'syncServerURI'
                        , 'trackerAutoStart', 'trackerStartTime'
                        , 'trackerFinishTime'
                    )
                    
                ) as xmlData
                
                from ch.entity
                where name = 'STGTSettings'
                order by id
            )
            
            , xmlelement(
                'double'
                , xmlattributes ('distanceFilter' as "name")
                , 35
            )
            , xmlelement(
                'double'
                , xmlattributes ('timeFilter' as "name")
                , 25
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
                , 'https://asa0.unact.ru/chest'
            )
            , xmlelement(
                'double'
                , xmlattributes ('trackerAutoStart' as "name")
                , 1
            )
            , xmlelement(
                'double'
                , xmlattributes ('trackerStartTime' as "name")
                , 7
            )
            , xmlelement(
                'double'
                , xmlattributes ('trackerFinishTime' as "name")
                , 21
            )
    ));
    
    set @result = (select xmlelement('d' , xmlattributes ('STGTSettings' as "name"),
                                           xmlagg(if r.[key] is not null
                                                  then xmlelement(if isnumeric(r.value) = 1
                                                                  then 'double'
                                                                  else 'string' endif
                                                     , xmlattributes(r.[key] as "name"), r.value)
                                                  else t.xmldatum endif))
                    from openxml(@result,'/*/*') 
                         with (name varchar(32) '@name', xmldatum xml '@mp:xmltext' ) as t
                                left outer join uac.roleData(@code,'STGTSettings') as r on t.name = r.[key]);

    return @result;
    
end;
