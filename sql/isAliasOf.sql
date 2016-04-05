create or replace function ch.isAliasOf(
    @name string, @ofName string
) returns BOOL begin

    declare @res BOOL;

    set @res = (
        select max (1) from ch.entityAlias
        where entity = @ofName
            and lower(@name) regexp aliasRe
    );

    return isnull(@res,0);

end;

create or replace function ch.aliasedColumnsRe(
    @name string, @ofName string
) returns string begin

    declare @res string;

    set @res = (
        select list(isnull(columnsRe,'.*'),'|') from ch.entityAlias
        where entity = @ofName
            and lower(@name) regexp aliasRe
    );

    return nullif(@res,'');

end;


create or replace function ch.filterXmldataByRe (
    @xmlData xml,
    @re text,
    @xmlDataOrigin xml default null
) returns xml begin

    declare @result xml;


        with dt as (
            select value, name
            from openxml(@xmlData, '/*/*')
                with (name STRING '@name', value xml '@mp:xmltext')
            where name regexp @re
        ), dto as (
            select value, name
            from openxml(@xmlDataOrigin, '/*/*')
                with (name STRING '@name', value xml '@mp:xmltext')
            where name not regexp @re
        )
        select xmlelement (rootName,
            xmlattributes (name, xid, code),
            (select xmlagg(value) from dt),
            (select xmlagg(value) from dto)
        )
        into @result
        from openxml (@xmlDataOrigin, '/*') with (
            rootName STRING '@mp:localname',
            name STRING '@name',
            xid STRING '@xid',
            code STRING '@code'
        )
    ;

    return @result;

end;
