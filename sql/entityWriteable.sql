create or replace function ch.entityWriteable(
    @entity long varchar,
    @UOAuthRoles xml
)
returns integer
begin

    declare @result integer;
    
    return 1;
    
    if exists(select p.role
                from openxml(@UOAuthRoles,'/*:response/*:roles/*:role')
                     with (role long varchar  '*:code') as t join ch.permission p on t.role = p.role
               where p.entity = @entity) then
        set @result = 1;
    else
        set @result = 0;
    end if;

    return @result;
    
end
;