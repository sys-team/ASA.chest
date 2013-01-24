create or replace function ch.chest(
    @url long varchar
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
    
    set @xid = newid();
    
    insert into ch.log with auto name
    select @xid as xid;
    
    set @request = http_body();
    
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