create or replace procedure ch.entityData(
    @entity long varchar
)
begin
    declare @sql long varchar;
    declare @cnt integer;
    
    set @sql = (select list(f)
                  from (
                select    
                'select e.id, e.version, e.author, e.xid, e.ts, e.cts ' as f
                union
                select nullif(
                (select list('(select c.xid as [' + r.name + '] '+
                        'from ch.relationship r join ch.entity c on r.child = c.id ' +
                        ' where r.parent = e.id and c.name = ''' + r.actor +''') ')
                   from ch.entityRole r
                  where entity = @entity),'')) as t);
                  
    set @cnt = (select count(*)
                  from ch.entityProperty
                 where entity = @entity);
                  
    set @sql = @sql +
                if @cnt <> 0 then ',x.* ' else '' endif +
                ' from ch.entity e ' +
                if @cnt <> 0 then 
                    ' outer apply (select ' +
                    (select list('[' + ch.remoteColumnName(property) + ']') +', remoteXid'
                      from ch.entityProperty where entity = @entity) +
                    ' from openxml(e.xmlData, ''/*:d'') with(' +
                    (select list('[' + ch.remoteColumnName(property) + '] long varchar ''*[@name="' + property + '"]''')
                       from ch.entityProperty where entity = @entity) +
                    ', remoteXid long varchar ''@xid'')) as x ' 
                else '' endif +
                ' where e.name = ''' + @entity +''' order by e.ts desc';
                
    message 'ch.entityData @sql = ', @sql;               
 
    execute immediate with result set on @sql;

end
;