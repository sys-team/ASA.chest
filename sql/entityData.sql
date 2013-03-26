create or replace procedure ch.entityData(
    @entity long varchar
)
begin
    declare @sql long varchar;
    
    set @sql = ch.entitySql(@entity);              
 
    execute immediate with result set on @sql;

end
;