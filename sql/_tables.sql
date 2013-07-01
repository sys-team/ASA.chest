grant connect to ch;
grant dba to ch;
comment on user ch is 'Chest service objects owner';

create table ch.entity(

    name varchar(512) not null,
    code varchar(512) null,
    xmlData xml,

    version integer default 1,
    not null foreign key(author) references uac.account,
    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ch.entity is 'Entity data'
;

create unique index ch_entity_named_code on ch.entity (name,code);

create table ch.relationship(

    parent integer not null,
    child integer not null,    
    parentXid GUID not null,
    childXid GUID not null,
    
    xmlData xml,
    
    version integer default 1,
    not null foreign key(author) references uac.account,
    
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

create table ch.attribute(

    name varchar(512),
    dataType varchar(512),
    value long varchar,
    
    xmlData xml,

    not null foreign key(parent) references ch.entity on delete cascade,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.attribute is 'Entity attribute'
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

    entityXid GUID,
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

    relationshipXid GUID,
    action integer not null,
    auser integer,
    xmlData xml,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.relationshipLog is 'Relationship log'
;
create index xk_relationshipLog_relationshipXid on ch.relationshipLog(relationshipXid)
;

create table ch.property(
    
    name varchar(512) not null unique,
    type varchar(512) not null,
    initial long varchar,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.property is 'Property'
;

create table ch.entityProperty(
    
    entity varchar(512) not null,
    property varchar(512) not null,
    initial long varchar,
    
    foreign key(property) references ch.property(name),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.entityProperty is 'Entity properties'
;

create table ch.entityRole(

    entity STRING not null,
    actor STRING not null,
    name STRING not null,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.entityRole is 'Entity roles'
;

create table ch.entityCompute(

    entity STRING not null,
    name STRING not null,
    type STRING not null,
    expression STRING not null,
    
    unique(entity, name),
       
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.entityCompute is 'Entity computed columns'
;

create table ch.dataSource(

    entity STRING not null unique,
    dataSource STRING,
    type STRING,
    FKDataSource STRING,
    FKType STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ch.dataSource is 'Entity data source'
;

create table ch.persistEntityData(

    entity STRING not null unique,
    persistTs datetime,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.persistEntityData is 'State of entity persist'
;


