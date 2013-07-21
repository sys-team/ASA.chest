create or replace procedure ch.createSP(
    @entity long varchar default null
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
        set @sql = 'create or replace procedure ch.' + c_name + '() begin ' +
                   ch.entitySql(c_name) + ' end ';
                   
        execute immediate @sql;
        
    end for;

end
;