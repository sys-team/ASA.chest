create or replace procedure ch.createPhantomTriggers(
    @tableName STRING,
    @execute integer default 0
)
begin
    declare @sql STRING;
    declare @tableId integer;
    declare @parentStart integer;
    declare @childStart integer;

    set @tableId = (
        select t.table_id
        from sys.systable t
        where t.table_name = regexp_substr(@tableName, '[^\.]*$')
            and t.creator = suser_id(regexp_substr(@tableName, '^.*(?=\.)'))
    );

    set @parentStart = 1000;
    set @childStart = 2000;

    for process as parents cursor for
    select u.user_name + '.' + t.table_name as c_parentName,
        pcol.column_name as c_primaryColumn,
        fcol.column_name as c_foreignColumn,
        number(*) as c_number
    from sys.sysfkey fk join sys.systable t on fk.primary_table_id = t.table_id
        join sys.sysuserperm u on u.user_id = t.creator
        join sys.sysidx i on i.table_id =  fk.foreign_table_id and i.index_id =  fk.foreign_index_id
        join sys.sysidxcol ic on ic.table_id  =i.table_id and ic.index_id = i.index_id
        join sys.syscolumn fcol on fcol.table_id = fk.foreign_table_id and fcol.column_id = ic.column_id
        join sys.syscolumn pcol on pcol.table_id = fk.primary_table_id and pcol.column_id = ic.primary_column_id
    where fk.foreign_table_id = @tableId
    do

        set @sql = string(
            'create or replace trigger ch.tbIU_ph_',
            replace(@tableName, '.', '_'), '_',
            c_foreignColumn,
            ' before insert, update order ', cast(@parentStart + c_number as varchar(24)),
            ' on ', @tableName,
            ' referencing old as deleted new as inserted for each row begin ',
            'if inserted.isPhantom = 0 and ',
            'exists(select * from ', c_parentName, ' where id = ',
            'inserted.', c_foreignColumn, ' and isPhantom = 1) ',
            'then set inserted.isPhantom = 1 ',
            'end if; ',
            'end'
        );

        if @execute = 0 then
            message 'ch.createPhantomTriggers @sql = ', @sql to client;
        else
            execute immediate @sql;
        end if;

    end for;

    for process2 as children cursor for
    select u.user_name + '.' + t.table_name as c_childName,
        pcol.column_name as c_primaryColumn,
        fcol.column_name as c_foreignColumn,
        number(*) as c_number
    from sys.sysfkey fk join sys.systable t on fk.foreign_table_id = t.table_id
        join sys.sysuserperm u on u.user_id = t.creator
        join sys.sysidx i on i.table_id =  fk.foreign_table_id and i.index_id =  fk.foreign_index_id
        join sys.sysidxcol ic on ic.table_id  =i.table_id and ic.index_id = i.index_id
        join sys.syscolumn fcol on fcol.table_id = fk.foreign_table_id and fcol.column_id = ic.column_id
        join sys.syscolumn pcol on pcol.table_id = fk.primary_table_id and pcol.column_id = ic.primary_column_id
    where fk.primary_table_id = @tableId
    do

        set @sql = string(
            'create or replace trigger ch.tU_ph_',
            replace(@tableName, '.', '_'), '_',
            replace(c_childName, ',', '_'), '_', c_foreignColumn,
            ' after update order ', cast(@childStart + c_number as varchar(24)),
            ' on ', @tableName,
            ' referencing old as deleted new as inserted for each row begin ',
            'if deleted.isPhantom = 1 and inserted.isPhantom = 0 then ',
            ' update ', c_childName, ' set isPhantom = 0 ',
            ' where ', c_foreignColumn, ' = inserted.', c_primaryColumn,
            ' end if; ',
            'end'
        );

        if @execute = 0 then
            message 'ch.createPhantomTriggers @sql = ', @sql to client;
        else
            execute immediate @sql;
        end if;

    end for;

end
;
