create or replace procedure ch.createView(
    @entity long varchar default null,
    @sourceOwner long varchar default 'ch',
    @isSp integer default 1
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
                   ' as select * from [' + @sourceOwner + '].[' + c_name +']' +
                   if @isSp = 1 then '()' else '' endif;
                   
        execute immediate @sql;
   end for;   
   
end
;