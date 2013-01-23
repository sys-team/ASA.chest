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

    not null foreign key(parent) references ch.entity on delete cascade,
    not null foreign key(child) references ch.entity on delete cascade,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ch.relationship is 'Entity relationship'
;
