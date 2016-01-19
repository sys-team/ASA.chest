create or replace function ch.parentId(
    @xid STRING,
    @tableName STRING
) returns IDREF
begin
    declare @result IDREF;
    declare @sql STRING;

    set @sql = string(
        'set @result = (select id from ',
        @tableName,
        ' where xid = ''', @xid, ''')'
    );

    execute immediate @sql;

    if @result is null then

        set @sql = string(
            ' insert into ', @tableName, ' with auto name ',
            'select ''', @xid, ''' as xid, 1 as isPhantom'
        );

        execute immediate @sql;

        set @result = @@identity;

    end if;

    return @result;

end
;
