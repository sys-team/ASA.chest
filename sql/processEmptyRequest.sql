create or replace function ch.processEmptyRequest(
    @code long varchar default isnull(nullif(replace(http_header('Authorization'), 'Bearer ', ''),''), http_variable('authorization:'))
)
returns xml
begin
    declare @result xml;
    
<<<<<<< HEAD
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
            
=======
    
    set @result = (select top 1 xmlelement('d'
        , xmlattributes ('STGTSettings' as "name")
        , xmlconcat(
            
            (select xmlagg(
                    if r.[key] is not null then xmlelement('string', xmlattributes(r.[key] as "name"), r.value) else xmldatum endif
                )
                from openxml(xmlData,'*/*') with (
                    name varchar(32) '@name'
                    , xmldatum xml '@mp:xmltext'
                ) as t left outer join uac.roleData (@code, 'STGTSettings') as r on t.name = r.[key]
                where t.name not in (
                    'ts'
                )
            ) 
>>>>>>> Settings from UOAuth "STGTSettings" role data
            , xmlelement(
                'date'
                , xmlattributes ('ts' as "name")
                , left(current utc timestamp, 19) + ' +0000'
            )
<<<<<<< HEAD
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
    
=======
            
        )) as xmlData
        
        from ch.entity, 
        where name = 'STGTSettings'
        order by id
    );

>>>>>>> Settings from UOAuth "STGTSettings" role data
    return @result;
    
end;