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
    declare @sqlstate STRING;
    declare @xid GUID;
    declare @service long varchar;
    declare @charSet long varchar;
    
    declare local temporary table #entity(
        name varchar(512),
        xid GUID,
        code varchar(512),
        xmlData xml,
        primary key(xid)
    );
    
    declare local temporary table #rel(
        name varchar(512),
        role varchar(512),
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

    ------------
    
    set @xid = newid();
    set @request = http_body();
    
    insert into ch.log with auto name
    select @xid as xid,
           @url as url,
           @code as code,
           if util.isXML(@request) = 1 then @request else null endif as httpBodyXML,
           if util.isXML(@request) = 0 then @request else null endif as httpBody;
           
         
    if util.isXML(@request) = 1 then
        update ch.log
           set httpBodyXML = @request
         where xid = @xid;
    end if;
    
    
    set @charSet = util.xmlCharset(@request);
    if @charSet is not null then
        set @request = csconvert(@request,'db_charset', @charSet);
    end if;
    
    if isnull(@request,'') = '' and isnull(@url,'') = '' then
        set @service = 'settings';
    end if;
    
    set @UOAuthRoles = uac.UOAuthAuthorize(@code); 
    -- message 'ch.chest @UOAuthRoles = ', @UOAuthRoles;
    
    set @UOAuthAccount = (
        select id
        from openxml(@UOAuthRoles,'/*:response/*:account')
            with (id integer '*:id')
    );

    update ch.log
       set account = @UOAuthAccount
    where xid = @xid;
    
    if @UOAuthAccount is null then
        
        set @response = ch.responseRootElement(xmlelement('error', xmlattributes('NotAuthorized' as "code")));
        
        update ch.log
            set response = @response
        where xid = @xid;
        
        CALL dbo.sa_set_http_header( '@HttpStatus', '401' );
        
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
            call ch.triggerEvent(@code);
            set @response = ch.makeAnswer();
        when 'get' then
            set @response = ch.get(@url);
        --when 'put' then
            --set @response = ch.put(@url);
        when 'settings' then
            set @response = ch.processEmptyRequest();
    end case;
    
    set @response = ch.responseRootElement(@response);
    
    update ch.log set
        response = @response,
        service = @service
    where xid = @xid;
    
    return @response;
    
    exception  
        when others then
        
            set @error = errormsg();
            set @sqlstate = SQLSTATE;
            
            if @error like 'RAISERROR executed: %' then
                set @errorCode =  trim(substring(@error, locate(@error,'RAISERROR executed: ') + length('RAISERROR executed: ')));
            end if;

            rollback;       
            
            call util.errorHandler('ch.chest', @sqlstate, @error);
            
            set @response = ch.responseRootElement(xmlelement('error', xmlattributes(@errorCode as "code"), @error));
            
            update ch.log
               set response = @response,
                   service = @service
            where xid = @xid;
            
            CALL dbo.sa_set_http_header( '@HttpStatus', '500' );
            
            return @response;
            
end
;