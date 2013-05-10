create or replace procedure ch.readData(
    @request xml
)
begin
    
    -- entities
    insert into #entity with auto name
        select
            coalesce(
                util.strtoxid(xid),
                (select top 1 xid from ch.entity where name=e.name and code=e.code order by id desc),
                (select top 1 xid from ch.entity where name=e.name order by id desc),
                newid()
            ) as xid,
            name,
            xmlData
        from openxml(@request, '/*/*:d') with (
            xid long varchar '@xid',
            name long varchar '@name',
            xmlData xml '@mp:xmltext'
        ) e
    ;
    
    --message 'ch.readData #1';
    
    -- entities from rel
    insert into #entity with auto name
        select distinct
            util.strtoxid(xid) as xid,
            name,
            null as xmlData
        from openxml(@request, '/*/*:d/*:d') with (
                xid long varchar '@xid',
                name long varchar '@name',
                xmlData xml '@mp:xmltext'
            ) as t
        where not exists( select *
            from #entity
            where xid = util.strtoxid(t.xid)
        ) and not exists( select *
            from ch.entity
            where xid =  util.strtoxid(t.xid)
        )
    ;
    
    --message 'ch.readData #2';
    
    -- attributes
    insert into #attribute with auto name
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
    insert into #rel with auto name
        select
            util.strtoxid(c.xid) as childXid,
            e.xid as parentXid,
            c.name,
            c.xmlData
        from #entity as e cross apply ( select *
            from openxml(e.xmldata, '/*/*:d') with (
                xid long varchar '@xid',
                name long varchar '@name',
                xmlData xml '@mp:xmltext'
            )
        ) as c
    ;
    
    --message 'ch.readData #3';
    
end
;