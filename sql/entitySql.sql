create or replace function ch.entitySql (
    @entity long varchar,
    @dateConversion integer default 0,
    @entitySrc string default @entity
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
                        ' where r.parent = e.id and c.xmldata is not null and c.name = ''' +
                        r.actor + 
                        ''' and isnull(r.role,c.name) = ''' + r.name + ''') as [' + r.name + '] ')
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
                            + if @dateConversion = 1 and p.type like'date%' then 'util.iOSTimestamp2DB(' else '' endif
                            + '[' + ch.remoteColumnName(ep.property) + ']'
                            + if @dateConversion = 1 and p.type like'date%' then ')' else '' endif
                            +', '+p.initial+') as '
                        else ''
                    endif
                    + if @dateConversion = 1 and p.type like'date%' then 'util.iOSTimestamp2DB(' else '' endif
                    + '[' + ch.remoteColumnName(ep.property) + ']'
                    + if @dateConversion = 1 and p.type like'date%' then ') as ' + '[' + ch.remoteColumnName(ep.property) + ']' else '' endif
                ) from ch.entityProperty ep join ch.property p
                where entity = @entity
            )
            + ' from openxml(e.xmlData, ''/*:d'') with( '
            + (select list(
                    '[' + ch.remoteColumnName(ep.property)
                    + '] ' + if p.type like 'date%' then 'string' else p.type endif
                    + ' ''*[@name="' + ep.property + '"]'''
                ) from ch.entityProperty ep join ch.property p
                where entity = @entity
            )
            + ')) as x ' 
        else '' endif
        
        + ' where e.name = ''' + @entitySrc +''''
        + ' and e.xmldata is not null'
    ;
    
    return @sql;
    
end;