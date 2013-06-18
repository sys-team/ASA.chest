create or replace procedure ch.createTable(
    @entity long varchar,
    @owner varchar(128) default 'ch',
    @isTemporary integer default 1,
    @forseDrop integer default 0
)
begin

    declare @sql text;
    declare @columns text;
    declare @roles text;
    
    for lloop as ccur cursor for
    select distinct
           entity as @name
        from ch.entityProperty
        where entity = @entity
            or @entity is null
    do
    
        if exists(select *
                    from sys.systable t join sys.sysuserperm u on t.creator = u.user_id
                   where t.table_name = @name
                     and u.user_name = @owner
                     and t.table_type in ('BASE', 'GBL TEMP')) and @forseDrop = 0 then
                     
            raiserror 55555 'Table %1!.%2! exists! use forseDrop option to regenerate', @owner, @name;
            return;
        else
    
            set @sql = 'drop table if exists ['+@owner+'].['+@name+']';
            execute immediate @sql;
            
        end if;
           
        set @columns = (
            select list(ch.remoteColumnName(p.name) + ' '+p.type, ', ')
            from 
                ch.entityProperty ep
                join ch.property p
            where ep.entity = @name
        );
        
        set @roles = (
            select list(er.name+' IDREF', ', ')
            from 
                ch.entityRole er
            where er.entity = @name
        );
        
        set @sql =
            'create ' + if @isTemporary = 1 then 'global temporary ' else '' endif
            + 'table ['+@owner+'].['+@name+'] ('
            + 'id ID, '
            + if @roles = '' then '' else @roles + ', ' endif
            + if @columns = '' then '' else @columns + ', ' endif
            + 'version int, author IDREF, xid GUID, ts TS, cts CTS, primary key(id), unique(xid)'
            +') ' + if @isTemporary = 1 then 'not transactional share by all' else '' endif
        ;
        
        --message 'ch.createTable @sql = ', @sql;
        execute immediate @sql;
        
        if @isTemporary = 0 then
            set @sql = 'create index [xk_' + @owner + '_' + @name + '_ts]' +
                        ' on [' + @owner + '].[' + @name + '](ts)';
                        
            --message 'ch.createTable @sql = ', @sql;
            execute immediate @sql;
                        
            if exists (select *
                         from ch.entityProperty
                        where entity = @name
                          and property = 'ts') then
                        
                set @sql = 'create index [xk_' + @owner + '_' + @name + '_remoteTs]' +
                            ' on [' + @owner + '].[' + @name + '](remoteTs)';
                            
                --message 'ch.createTable @sql = ', @sql;
                execute immediate @sql;
                
            end if;
        end if; 
    end for;
    
    -- Foreign keys
    if @isTemporary = 0 then
        for lloop2 as ccur2 cursor for
        select distinct
               entity as c_entity,
               actor as c_actor,
               name as c_name
          from ch.entityRole
         where entity = @entity
            or @entity is null
        do
        
            set @sql = 'alter table [' + @owner + '].[' + c_entity + ']'
                     + ' add foreign key([' + c_name + ']) references [' + @owner + '].[' + c_actor + ']';
                     
            execute immediate @sql;
        
        end for;
    end if;

end;