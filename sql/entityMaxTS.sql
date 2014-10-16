create or replace function ch.entityMaxTS(
    @name STRING
) returns timestamp
begin

    declare @result timestamp;
    
    set @result = (
        select max(ts) from ch.entity where name = @name
    );
    
    return @result;
    
end;