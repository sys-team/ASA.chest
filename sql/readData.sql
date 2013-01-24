create or replace procedure ch.readData(
    @request xml
)
begin
    
    -- entities
    insert into #entity with auto name
    select util.strtoxid(xid) as xid,
           name,
           xmlData
      from openxml(@request, '/*/*:d')
           with(xid long varchar '@xid', name long varchar '@name', xmlData xml '@mp:xmltext');
           
    --message 'ch.readData #1';
           
    -- entities from rel
    insert into #entity with auto name
    select distinct util.strtoxid(xid) as xid,
           name
      from openxml(@request, '/*/*:d/*:d')
      with(xid long varchar '@xid', name long varchar '@name', xmlData xml '@mp:xmltext') as t
     where not exists(select *
                        from #entity
                       where xid = util.strtoxid(t.xid));
                       
    --message 'ch.readData #2';
           
    -- rels
    insert into #rel with auto name
    select util.strtoxid(xid) as childXid,
           util.strtoxid(parentXid) as parentXid,
           name,
           xmlData
      from openxml(@request, '/*/*:d/*:d')
           with(xid long varchar '@xid', parentXid long varchar '../@xid' ,name long varchar '@name', xmlData xml '@mp:xmltext');
           
    --message 'ch.readData #3';
           
end
;