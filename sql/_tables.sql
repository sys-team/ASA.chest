grant connect to ch;
grant dba to ch;

create table ch.entity(

    name varchar(512),
    xmlData xml,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ch.entity is 'Entity data'
;

create table ch.relationship(

    parent integer not null,
    child integer not null,    
    parentXid GUID not null,
    childXid GUID not null,
    
    xmlData xml,
    
    not null foreign key(parent) references ch.entity on delete cascade,
    not null foreign key(child) references ch.entity on delete cascade,
    
    unique(parent, child),
    unique(parentXid, childXid),
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.relationship is 'Entity relationship'
;
