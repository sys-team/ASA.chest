create or replace function ch.mergeXml(
    @first xml,
    @second xml,
    @rootName STRING default 'd',
    @firstPath STRING default '/*/*',
    @secondPath STRING default '/*/*'
) returns xml
begin
    declare @result xml;

    set @result = (
        select xmlelement (@rootName,
            xmlattributes (name, xid),
            (select xmlagg(coalesce(f.value, s.value))
                from (
                    select *
                    from openxml(@first, @firstPath)
                    with (name STRING '@name', value xml '@mp:xmltext')
                ) as f full outer join (
                    select *
                    from openxml(@second, @secondPath)
                    with (name STRING '@name', value xml '@mp:xmltext')
                ) as s on f.name = s.name
            )
        )
        from openxml (@first, '/*') with (
            name STRING '@name',
            xid STRING '@xid'
        )
    );
    
    return @result;
    
end;