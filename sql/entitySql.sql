create or replace function ch.entitySql (
    @entity long varchar
)
returns long varchar
begin
    declare @sql long varchar;
    declare @cnt integer;
    
    set @sql = (
        select list(f)
        from (
            select    
                'select e.id ' as f
            union select nullif(
                (select list('(select c.id '+
                        'from ch.relationship r join ch.entity c on r.child = c.id ' +
                        ' where r.parent = e.id and c.name = ''' + r.actor +''') as [' + r.name + '] ')
                    from ch.entityRole r
                    where entity = @entity
                ),
                ''
            )
        ) as t
    );
    
    set @cnt = (
        select count(*)
        from ch.entityProperty
        where entity = @entity
    );
    
    set @sql = @sql
        
        +if @cnt <> 0
            then ',' +
              (select list('x.[' + ch.remoteColumnName(property) + ']')
                from ch.entityProperty where entity = @entity)
            else ''
        endif
        
        +', e.version, e.author, e.xid, e.ts, e.cts'
        + ' from ch.entity e '
        
        + if @cnt <> 0 then 
            ' outer apply (select '
            + (select list(
                    + if p.initial is not null
                        then 'isnull('
                            + '[' + ch.remoteColumnName(ep.property) + ']'
                            +', '+p.initial+') as '
                        else ''
                    endif
                    + '[' + ch.remoteColumnName(ep.property) + ']'
                ) from ch.entityProperty ep join ch.property p
                where entity = @entity
            )
            + ' from openxml(e.xmlData, ''/*:d'') with( '
            + (select list(
                    '[' + ch.remoteColumnName(ep.property)
                    + '] ' + p.type
                    + ' ''*[@name="' + ep.property + '"]'''
                ) from ch.entityProperty ep join ch.property p
                where entity = @entity
            )
            + ')) as x ' 
        else '' endif
        
        +' where e.name = ''' + @entity +''''
    ;
    
    return @sql;
    
end;