create or replace procedure ch.createView(
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
        set @sql = 'create or replace view ch.' + c_name +
                   ' as select * from ch.' + c_name +'()';
                   
        execute immediate @sql;
   end for;   
   
end
;