create or replace procedure ch.createSP(
    @entity long varchar default null
)
begin
    declare @sql long varchar;
    
    for lloop as ccur cursor for
    select distinct
           name as c_name
      from ch.entity
     where name = @entity
        or @entity is null
    do
        set @sql = 'create or replace procedure ch.' + c_name + '() begin ' +
                   ch.entitySql(c_name) + ' end ';
                   
        execute immediate @sql;
        
    end for;

end
;