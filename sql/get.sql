create or replace function ch.get(
    @url long varchar,
    @pageSize integer default if isnumeric(http_variable('page-size:')) = 1 then http_variable('page-size:') else 10 endif,
    @pageNumber integer default if isnumeric(http_variable('page-number:')) = 1 then http_variable('page-number:') else 1 endif
)
returns xml
begin
    declare @result xml;
    declare @entity long varchar;
    declare @sql long varchar;
    declare @where long varchar;
    declare @whereRel long varchar;
    declare @whereRel2 long varchar;
    
    declare local temporary table #variable(name long varchar,
                                            value long varchar,
                                            operator varchar(64) default '=');
                                            
    -- http variables
    insert into #variable with auto name
    select name,
           value
      from util.httpVariables();
      
    -- parse url
    select entity
      into @entity
      from openstring(value @url)
           with (service long varchar, entity long varchar)
           option(delimited by '/') as t;
           
    --
    call ch.parseVariables();
    
    delete from #variable
     where name in ('url')
        or name like '%:';
    
    
    set @sql = 'select top ' + cast(@pageSize as varchar(64)) + ' ' +
               ' start at ' + cast((@pageNumber -1) * @pageSize + 1 as varchar(64)) +
               ' e.xmlData ' +
               ' from ch.entity e where name = ''' + @entity + '''';
               
    set @where  = (select list('exists(select * from ch.attribute where parent = e.id and name = ''' +
                          name + ''' and value ' + operator + value + ')', ' and ')
                     from #variable
                    where util.strtoxid(replace(value,'''','')) is null);
                    
    set @whereRel = (select list('exists(select * from ch.relationship r join ch.entity p on r.child = p.id ' +
                                     'where r.parent = e.id and p.name = ''' + name +''' and r.parentXid = ' + value + ')', ' and ')
                       from #variable
                      where util.strtoxid(replace(value,'''','')) is not null
                        and name<> 'xid');
                        
    set @whereRel2 = (select list('exists(select * from ch.relationship r join ch.entity p on r.parent = p.id ' +
                                     'where r.child = e.id and p.name = ''' + name +''' and r.parentXid = ' + value + ')', ' and ')
                        from #variable
                       where util.strtoxid(replace(value,'''','')) is not null
                         and name<> 'xid');
             
    if @where <> '' then
        set @sql = @sql + ' and ' + @where;
    end if;
    
    if @whereRel <> '' then
        set @sql = '(' + @sql + ' and ' + @whereRel;
    end if;
    
    if @whereRel2 <> '' then
        set @sql = @sql + ' or ' + @whereRel2 + ')';
    else
        set @sql = @sql +')';
    end if;
               
    message 'ch.get @sql = ', @sql;           
               
    set @sql = 'set @result = (select xmlagg(xmlData) from (' + @sql + ') as t)';
    
    --message 'ch.get @sql = ', @sql;
    
    execute immediate @sql;

    return @result;
end
;