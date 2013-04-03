create global temporary table ch.log(
    
    service varchar(128),
    response xml,
    code varchar(1024),
    url long varchar,
    httpBody long varchar default http_body(),
    callerIP varchar(128) default connection_property('ClientNodeAddress'),
    
    account integer,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;
