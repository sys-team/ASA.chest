create or replace procedure ch.readData(
    @request xml
)
begin
    
    -- entities
    insert into #entity on existing update with auto name
        select
            coalesce(
                util.strtoxid(xid),
                (select top 1 xid from ch.entity where name=e.name and code=e.code order by id desc),
                newid()
            ) as xid,
            name,
            code,
            xmlData,
            type
        from openxml(@request, '/*/*') with (
            xid long varchar '@xid',
            name long varchar '@name',
            code long varchar '@code',
            xmlData xml '@mp:xmltext',
            type varchar(32) '@mp:localname'
        ) e
        where type in ('d','m')
    ;
    
    --message 'ch.readData #1';
    
    -- entities from rel
    insert into #entity on existing update with auto name
        select distinct
            coalesce(
                util.strtoxid(xid),
                (select top 1 xid from ch.entity where name = t.name and code = t.code order by id desc),
                (select top 1 xid from #entity where name = t.name and code = t.code),
                newid()
            ) as xid,
            name,
            null as xmlData
        from openxml(@request, '/*/*/*:d') with (
                xid long varchar '@xid',
                name long varchar '@name',
                code long varchar '@code',
                xmlData xml '@mp:xmltext'
            ) as t
        where not exists( select *
            from #entity
            where xid = coalesce(
                            util.strtoxid(xid),
                            (select top 1 xid from ch.entity where name = t.name and code = t.code order by id desc),
                            (select top 1 xid from #entity where name = t.name and code = t.code))
        ) and not exists( select *
            from ch.entity
            where xid =  coalesce(
                            util.strtoxid(xid),
                            (select top 1 xid from ch.entity where name = t.name and code = t.code order by id desc),
                            (select top 1 xid from #entity where name = t.name and code = t.code))
        )
    ;
    
    --message 'ch.readData #2';
    
    -- attributes
    insert into #attribute on existing update with auto name
        select
            c.name,
            c.dataType,
            c.value,
            c.xmlData,
            e.xid parentXid,
            e.name parentName
        from #entity as e cross apply ( select *
            from openxml(e.xmldata, '/*/*') with (
                name long varchar '@name', 
                dataType long varchar '@mp:localname', 
                value long varchar '.',
                xmlData xml '@mp:xmltext'
            ) where dataType <> 'd'
        ) as c 
    ;
    
    -- rels
    insert into #rel on existing update with auto name
        select
            coalesce(
                util.strtoxid(c.xid),
                (select top 1 xid from ch.entity where name = c.name and code = c.code order by id desc),
                (select top 1 xid from #entity where name = c.name and code = c.code)
            ) as childXid,
            e.xid as parentXid,
            c.name,
            c.xmlData
        from #entity as e cross apply ( select *
            from openxml(e.xmldata, '/*/*:d') with (
                xid long varchar '@xid',
                name long varchar '@name',
                code long varchar '@code',
                xmlData xml '@mp:xmltext'
            )
        ) as c
    ;
    
    --message 'ch.readData #3';
    
end;