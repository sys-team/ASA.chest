create or replace procedure ch.entityData(
    @entity long varchar
)
begin
    declare @sql long varchar;
    
    set @sql =  --'insert into #t with auto name ' +
                'select e.id, e.version, e.lastUser, e.xid, e.ts, e.cts, '+ 
                'x.* from ch.entity e outer apply (select ' +
                (select list('[' + ch.remoteColumnName(property) + ']') +', remoteXid'
                  from ch.entityProperty where entity = @entity) +
                ' from openxml(e.xmlData, ''/*:d'') with(' +
                (select list('[' + ch.remoteColumnName(property) + '] long varchar ''*[@name="' + property + '"]''')
                   from ch.entityProperty where entity = @entity) +
                ', remoteXid long varchar ''@xid'')) as x ' +
                ' where e.name = ''' + @entity +'''';
                
    --message 'ch.entityData @sql = ', @sql;               
 
    execute immediate with result set on @sql;

end
;