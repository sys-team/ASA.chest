create or replace procedure ch.persistData(
    @startTs datetime,
    @owner varchar(128) default 'ch',
    @entity long varchar default null
)
begin
    declare @sql long varchar;

    for lloop as ccur cursor for
    select distinct
           entity as c_entity
      from ch.entityProperty
     where (entity = @entity
        or @entity is null)
    do
        if exists(select *
                    from sys.systable t join sys.sysuserperm u on t.creator = u.user_id
                   where t.table_name = c_entity
                     and u.user_name = @owner
                     and t.table_type in ('BASE', 'GBL TEMP')) then
                     
            set @sql = 'insert into [' + @owner + '].[' + c_entity + '] on existing update with auto name ' +
                       ch.entitySql(c_entity) +
                       ' and e.ts >= ''' + cast(@startTs as varchar(24)) +'''';
                       
            -- message 'ch.persistData @sql = ', @sql;
            
            execute immediate @sql;
            
            commit;
                     
        end if;

    end for;

end
;