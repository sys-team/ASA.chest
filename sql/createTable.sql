create or replace procedure ch.createTable(
    @entity long varchar
)
begin

    declare @sql text;
    declare @columns text;
    declare @roles text;
    
    for lloop as ccur cursor for
    select distinct
           name as @name
        from ch.entity
        where name = @entity
            or @entity is null
    do  
        set @sql = 'drop table if exists ch.'+@name;
        
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
            'create global temporary table ch.' + @name + '('
            + 'id ID, '
            + if @columns = '' then '' else @columns + ', ' endif
            + if @roles = '' then '' else @roles + ', ' endif
            + 'xid GUID, ts TS, cts CTS, primary key(id), unique(xid)'
            +') not transactional share by all'
        ;
        
        execute immediate @sql;
        
    end for;   

end;