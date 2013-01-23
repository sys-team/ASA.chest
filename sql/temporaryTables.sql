create global temporary table ch.log(
    
    response xml,
    httpBody long varchar default http_body(),
    callerIP varchar(128) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;
