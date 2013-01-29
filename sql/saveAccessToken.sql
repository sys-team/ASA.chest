create or replace function ch.saveAccessToken(
    @UOAuthRoles xml,
    @token long varchar,
    @authSystem long varchar default 'UOAuth'
)
returns integer
begin
    declare @result integer;

    set @result = (select id
                     from ch.accessToken
                    where token = @token);
    
    if @result is null then
        
        insert into ch.accessToken with auto name
        select @token as token,
               @authSystem as authSystem,
               ts as tokenTs,
               expiresIn as tokenExpiresIn,
               xmlData
          from openxml(@UOAuthRoles, '/*:response/*:token')
               with(ts datetime '*:ts', expiresIn integer '*:expiresIn', xmlData xml '@mp:xmltext');
        
        set @result = @@identity;
    
    end if;

    return @result;
end
;