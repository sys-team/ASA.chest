create or replace procedure ch.readData(
    @request xml
)
begin
    
    -- entitys
    insert into #entity with auto name
    select util.strtoxid(xid) as xid,
           name,
           xmlData
      from openxml(@request, '/*/*:d')
           with(xid long varchar '@xid', name long varchar '@name', xmlData xml '@mp:xmltext');
           
    -- rels
    insert into #rel with auto name
    select util.strtoxid(xid) as xid,
           util.strtoxid(parentXid) as parentXid,
           name
      from openxml(@request, '/*/*:d/*:d')
           with(xid long varchar '@xid', parentXid long varchar '../@xid' ,name long varchar '@name');
           
end
;