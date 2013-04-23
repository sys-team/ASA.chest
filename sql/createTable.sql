create or replace procedure ch.createTable(
    @entity long varchar,
    @owner varchar(128) default 'ch'
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
            select list(p.name+' '+p.type, ', ')
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
            'create global temporary table ['+@owner+'].['+@name+'] ('
            + 'id ID, '
            + if @roles = '' then '' else @roles + ', ' endif
            + if @columns = '' then '' else @columns + ', ' endif
            + 'version int, author IDREF, xid GUID, ts TS, cts CTS, primary key(id), unique(xid)'
            +') not transactional share by all'
        ;
        
        message @sql to client;
        execute immediate @sql;
        
    end for;   

end;