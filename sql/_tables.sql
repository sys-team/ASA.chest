grant connect to ch;
grant dba to ch;

create table ch.entity(

    name varchar(512),
    xmlData xml,

    version integer default 1,
    lastUser integer,

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
    
    version integer default 1,
    lastUser integer,
    
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

create table ch.permission(

    role STRING,
    entity STRING,
    writeable BOOL,
    readable BOOL,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table ch.permission is 'Mapping UOAuth roles to entities'
;


create table ch.entityLog(

    entityXid,
    action integer not null,
    auser integer,
    xmlData xml,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.entityLog is 'Entity log'
;
create index xk_entityLog_entityXid on ch.entityLog(entityXid)
;

create table ch.relationshipLog(

    relationshipXid,
    action integer not null,
    auser integer,
    xmlData xml,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.relationshipLog is 'Relationship log'
;
create index xk_entityLog_entityXid on ch.entityLog(entityXid)
;



