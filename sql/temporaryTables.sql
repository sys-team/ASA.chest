create global temporary table ch.log(

    service varchar(128),
    processing varchar(32),
    response xml,
    code varchar(1024),
    url long varchar,
    httpBody long varchar default http_body(),
    httpBodyXML xml,
    callerIP varchar(128) default connection_property('ClientNodeAddress'),
    deviceUUID string default http_header ('DeviceUUID'),

    account integer,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)  not transactional share by all
;
