create or replace procedure ch.readData (
    @request xml,
    @code long varchar default util.HTTPVariableOrHeader (),
    @logXid GUID default null
)
begin

    message 'ch.readData ', @UOAuthAccount, ' ', @code, ' #0'
        debug only
    ;

    update ch.log set
        processing = 'readData'
    where xid = @logXid;

    -- entities

    insert into #entity on existing update with auto name
        select
            coalesce(
                util.strtoxid(e.xid),
                (select top 1 xid from ch.entity where name=e.name and code=e.code order by id desc),
                newid()
            ) as xid,
            isnull (ea.entity,e.name) as name,
            e.code,
            e.xmlData,
            e.type
        from openxml(@request, '/*/*') with (
            xid long varchar '@xid',
            name long varchar '@name',
            code long varchar '@code',
            xmlData xml '@mp:xmltext',
            type varchar(32) '@mp:localname'
        ) e left join ch.EntityAlias ea
            on ea.aliasRe = e.name and ea.isFullAlias = 1
        where type in ('d','m')
    ;

    message 'ch.readData ', @UOAuthAccount, ' ', @code, ' #1 ', @@rowcount
        debug only
    ;

    update ch.log set
        processing = 'readData:insert'
    where xid = @logXid;

    update #entity $e set
        type = 'd', name = e.name, code = e.code,
        xmldata = ch.filterXmldataByRe (
            $e.xmlData, ch.aliasedColumnsRe($e.name,e.name), e.xmlData
        )
    from ch.entity e
    where e.xid = $e.xid
        and ch.isAliasOf ($e.name, e.name) = 1
    ;

    message 'ch.readData ', @UOAuthAccount, ' ', @code, ' #3'
        debug only
    ;

    update ch.log set
        processing = 'readData:filterXmldataByRe'
    where xid = @logXid;

    insert into #entityIgnored with auto name
    select xid, name, xmlData
    from #entity where exists (
        select *
        from ch.entity
        where entity.xid = #entity.xid
            and entity.name <> #entity.name
            and #entity.type <> 'm'
    );

    update ch.log set
        processing = 'readData:entityIgnored'
    where xid = @logXid;

    if @@rowcount > 0 then

        delete #entity
        from #entityIgnored
        where #entityIgnored.xid = #entity.xid
        ;

        message 'ch.readData deleted: ', @@rowcount
            debug only
        ;

        update ch.log set
            processing = 'readData:entityIgnored:deleted'
        where xid = @logXid;

    end if;

    -- entities from rel
    insert into #entity on existing update with auto name
        select distinct
            coalesce (
                util.strtoxid(xid),
                (select top 1 xid from ch.entity where name = t.name and code = t.code order by id desc),
                (select max(xid) from #entity where name = t.name and code = t.code),
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
                (select max(xid) from #entity where name = t.name and code = t.code)
            )
        ) and not exists( select *
            from ch.entity
            where xid =  coalesce(
                util.strtoxid(xid),
                (select top 1 xid from ch.entity where name = t.name and code = t.code order by id desc),
                (select max(xid) from #entity where name = t.name and code = t.code)
            )
        )
    ;

    message 'ch.readData ', @UOAuthAccount, ' ', @code, ' #3'
        debug only
    ;

    update ch.log set
        processing = 'readData:insert:fromRel'
    where xid = @logXid;

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

    message 'ch.readData ', @UOAuthAccount, ' ', @code, ' #end'
        debug only
    ;

    update ch.log set
        processing = 'readData:insert:rel'
    where xid = @logXid;

end;
