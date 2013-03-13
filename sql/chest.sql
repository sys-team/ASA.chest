create or replace function ch.chest(
    @url long varchar,
    @code long varchar default isnull(nullif(replace(http_header('Authorization'), 'Bearer ', ''),''), http_variable('authorization:'))
)
returns xml
begin
    declare @response xml;
    declare @request xml;
    declare @error long varchar;
    declare @errorCode long varchar;
    declare @xid GUID;
    declare @service long varchar;
    
    declare local temporary table #entity(
        name varchar(512),
        xid GUID,
        xmlData xml,
        primary key(xid)
    );
                                          
    declare local temporary table #rel(
        name varchar(512),
        childXid GUID,
        parentXid GUID,
        xmlData xml,
        primary key(childXid, parentXid)
    );
                                       
    declare local temporary table #attribute(
        name varchar(512),
        dataType varchar(512),
        value long varchar,
        xmlData xml,
        parentXid GUID,
        parentName varchar(512),
        primary key(parentXid, name)
    );
    
    if varexists('@UOAuthAccount') = 0 then                                   
        create variable @UOAuthAccount integer;
    end if;
    
    if varexists('@UOAuthRoles') = 0 then
        create variable @UOAuthRoles xml;
    end if;
    
    if varexists('@accessTokenId') = 0 then
        create variable @accessTokenId integer;
    end if;
    ------------
    
    set @xid = newid();
    
    insert into ch.log with auto name
    select @xid as xid,
           @url as url,
           @code as code;
    
    set @request = http_body();
    
    if isnull(@request,'') = '' and isnull(@url,'') = '' then
        set @service = 'settings';
    end if;
    
    set @UOAuthRoles = util.UOAuthAuthorize(@code); 
    -- message 'ch.chest @UOAuthRoles = ', @UOAuthRoles;
    
    set @UOAuthAccount = (select id
                            from openxml(@UOAuthRoles,'/*:response/*:account')
                            with (id integer '*:id'));
                            
    set @accessTokenId = ch.saveAccessToken(@UOAuthRoles, @code);                            

    if @UOAuthAccount is null then
        set @response = ch.responseRootElement(xmlelement('error', xmlattributes('NotAuthorized' as "code")));
        update ch.log
           set response = @response
         where xid = @xid;
            
        return @response;
    end if;
    
    -- parse url
    if @url is not null then
        select service
          into @service
          from openstring(value @url)
               with (service long varchar)
               option(delimited by '/') as t;
    elseif @service is null then
        set @service = 'chest';
    end if;

    ------------
   -- message 'ch.chest @service = ', @service;
    
    case @service
        when 'chest' then
            call ch.readData(@request);
            call ch.saveData();
            set @response = ch.makeAnswer();
        when 'get' then
            set @response = ch.get(@url);
        when 'put' then
            set @response = ch.put(@url);
        when 'settings' then
            set @response = ch.processEmptyRequest();
    end case;
    
    set @response = ch.responseRootElement(@response);
    
    update ch.log
       set response = @response,
           service = @service
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
               set response = @response,
                   service = @service
            where xid = @xid;
            
            return @response;
            
end
;