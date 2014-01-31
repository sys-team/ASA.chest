create or replace function ch.mergeXml(
    @first xml,
    @second xml,
    @rootName STRING default 'd',
    @firstPath STRING default '/*:m/*',
    @secondPath STRING default '/*:d/*'
)
returns xml
begin
    declare @result xml;
    declare @xid STRING;
    declare @name STRING;
    
    declare local temporary table #data(
        name STRING not null,
        firstValue xml,
        secondValue xml,
        primary key(name)
    );
    
    --message 'ch.mergeXml @first = ' , @first;
    --message 'ch.mergeXml @second = ' , @second;
    
    select name,
           xid
      into @name, @xid
     from openxml(@first, '/*')
          with(name STRING '@name', xid STRING '@xid');
    
    insert into #data with auto name
    select name,
           firstValue
      from openxml(@first, @firstPath)
           with(name STRING '@name', firstValue xml '@mp:xmltext');
           
    insert into #data on existing update with auto name
    select name,
           secondValue
      from openxml(@second, @secondPath)
           with(name STRING '@name', secondValue xml '@mp:xmltext');
    
    --set @result = (select * from #data for xml auto);
    --message 'ch.mergeXml #data= ', @result;
    
    set @result = (select xmlelement(@rootName, xmlattributes(@name as "name", @xid as "xid"),
                                                xmlagg(coalesce(firstValue, secondValue))) from #data);    
    
    return @result;
    
end
;