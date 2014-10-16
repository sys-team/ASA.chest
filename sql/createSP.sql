create or replace procedure ch.createSP(
    @entity string default null,
    @entitySrc string default null,
    @owner string default 'ch'
)
begin
    declare @sql long varchar;
    
    for lloop as ccur cursor for
    select distinct
           entity as c_name
      from ch.entityProperty
     where (entity = @entity
        or @entity is null)
    union select @entity
    do
        set @sql = 'create or replace procedure [' + @owner + '].'
            + '[' + c_name + ']'
            + '() begin '
            + ch.entitySql(c_name, 0, isnull(@entitySrc, c_name))
            + ' end '
        ;
        
        message @sql to client;
        
        execute immediate @sql;
        
    end for;

end;