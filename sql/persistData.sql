create or replace procedure ch.persistData(
    @owner varchar(128) default 'ch',
    @entity long varchar default null
)
begin
    declare @sql long varchar;
    declare @ts datetime;
    declare @ets datetime;
    
    set @ets = now();

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
                     
            set @ts = isnull((select persistTs
                                from ch.persistEntityData
                               where entity = c_entity), '1971-07-25');
                     
            set @sql = 'insert into [' + @owner + '].[' + c_entity + '] on existing update with auto name ' +
                       ch.entitySql(c_entity) +
                       ' and e.ts between ''' + cast(@ts as varchar(24)) +''' and ''' + cast(@ets as varchar(24)) +'''';
                       
            --message 'ch.persistData @sql = ', @sql;
            
            execute immediate @sql;
            
            insert into ch.persistEntityData on existing update with auto name
            select (select id
                      from persistEntityData
                     where entity = c_entity) as id,
                   c_entity as entity,
                   @ets as persistTs;
                   
            -- message 'ch.persistData @sql = ', @sql;
                
            commit;
                     
        end if;

    end for;

end
;