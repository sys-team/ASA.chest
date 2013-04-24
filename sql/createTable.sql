create or replace procedure ch.createTable(
    @entity long varchar,
    @owner varchar(128) default 'ch',
    @isTemporary integer default 1
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
        set @sql = 'drop table if exists ['+@owner+'].['+@name+']';
        
        execute immediate @sql;
        
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
        
        end if;
        
    end for;   

end;