create or replace function ch.chest(
    @url long varchar,
    @code long varchar default util.HTTPVariableOrHeader ()
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
        type varchar(24) default 'd',
        xmlData xml,
        primary key(xid)
    );

    declare local temporary table #entityIgnored(
        name varchar(512),
        xid GUID,
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
    set @request = ch.screenChars(http_body());
    ---- message 'ch.chest util.isXML(@request) = ', util.isXML(@request);
    set @charSet = util.xmlCharset(@request);

    if @charSet is not null then
        set @request = csconvert(@request,'db_charset', @charSet);
    end if;

    insert into ch.log with auto name select
        @xid as xid,
        @url as url,
        @code as code,
        if util.isXML(@request) = 1 then @request else null endif as httpBodyXML,
        if util.isXML(@request) = 0 then @request else null endif as httpBody,
        isnull(
            util.HTTPVariableOrHeader('x-real-ip'),
            connection_property('ClientNodeAddress')
        ) as callerIP
    ;

    if isnull(@request,'') = '' and isnull(@url,'') = '' then
        set @service = 'settings';
    end if;

    set @UOAuthRoles = uac.UOAuthAuthorize(@code);
    -- -- message 'ch.chest @UOAuthRoles = ', @UOAuthRoles;

    set @UOAuthAccount = (
        select account
        from uac.token
        where token = @code
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
    -- message 'ch.chest #1 ', @UOAuthAccount;

    case @service
        when 'chest' then
            call ch.readData(@request,@code);
            -- message 'ch.chest #1.1 ', @UOAuthAccount;
            call ch.saveData();
            -- message 'ch.chest #1.2 ', @UOAuthAccount;
            call ch.triggerEvent(@code);
            -- message 'ch.chest #1.3 ', @UOAuthAccount;
            set @response = ch.makeAnswer();
            -- message 'ch.chest #1.4 ', @UOAuthAccount;
        when 'get' then
            set @response = ch.get(@url);
        --when 'put' then
            --set @response = ch.put(@url);
        when 'settings' then
            set @response = ch.processEmptyRequest();
    end case;

    -- message 'ch.chest #2 ', @UOAuthAccount;

    set @response = ch.responseRootElement(@response);

    update ch.log set
        response = @response,
        service = @service
    where xid = @xid;

    -- message 'ch.chest #3 ', @UOAuthAccount;

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

            call dbo.sa_set_http_header( '@HttpStatus', '500' );

            return @response;

end
;
