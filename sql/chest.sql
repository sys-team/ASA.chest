create or replace function ch.chest(
    @url long varchar,
    @code long varchar default isnull(nullif(replace(http_header('Authorization'), 'Bearer ', ''),''), http_variable('code'))
)
returns xml
begin
    declare @response xml;
    declare @request xml;
    declare @error long varchar;
    declare @errorCode long varchar;
    declare @xid GUID;
    
    declare local temporary table #entity(name varchar(512),
                                          xid GUID,
                                          xmlData xml,
                                          primary key(xid));
                                          
    declare local temporary table #rel(name varchar(512),
                                       childXid GUID,
                                       parentXid GUID,
                                       xmlData xml,
                                       primary key(childXid, parentXid));
    
    if varexists('@UOAuthAccount') = 0 then                                   
        create variable @UOAuthAccount integer;
    end if;
    
    if varexists('@UOAuthRoles') = 0 then
        create variable @UOAuthRoles xml;
    end if;
    ------------
    
    set @xid = newid();
    
    insert into ch.log with auto name
    select @xid as xid;
    
    set @request = http_body();
    
    set @UOAuthRoles = util.UOAuthAuthorize(@code); 
    -- message 'ch.chest @UOAuthRoles = ', @UOAuthRoles;
    
    set @UOAuthAccount = (select id
                            from openxml(@UOAuthRoles,'/*:response/*:account')
                            with (id integer '*:id'));
                            

    if @UOAuthAccount is null then
        set @response = ch.responseRootElement(xmlelement('error', xmlattributes('NotAuthorized' as "code")));
        update ch.log
           set response = @response
         where xid = @xid;
            
        return @response;
    end if;

    
    call ch.readData(@request);
    call ch.saveData();
    set @response = ch.makeAnswer();
    
    set @response = ch.responseRootElement(@response);
    
    update ch.log
       set response = @response
     where xid = @xid;
    
    return @response;
    
    exception  
        when others then
        
            set @error = errormsg();
            if @error like 'RAISERROR executed: %' then
                set @errorCode =  trim(substring(@error, locate(@error,'RAISERROR executed: ') + length('RAISERROR executed: ')));
            end if;

            rollback;       
            
            set @response = ch.responseRootElement(xmlelement('error', xmlattributes(@errorCode as "code"), @error));
            
            update ch.log
               set response = @response
            where xid = @xid;
            
            return @response;
            
end
;