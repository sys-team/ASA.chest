------------
-- entity
------------
create or replace trigger ch.tbU_entity before update on ch.entity
referencing new as inserted old as deleted
for each row
begin

    set inserted.version = isnull(deleted.version,1) + 1;

    if varexists('@UOAuthAccount') = 1 then
        set inserted.author = @UOAuthAccount;
    end if;

    if inserted.xmlData <> deleted.xmlData
    and deleted.status not in (0, -1) then

        set inserted.status = 0;

    end if;

end
;

create or replace trigger ch.tbI_entity before insert on ch.entity
referencing new as inserted
for each row
begin

    if varexists('@UOAuthAccount') = 1 then
        set inserted.author = @UOAuthAccount;
    end if;

end
;

------------
-- relationship
------------
create or replace trigger ch.tbU_relationship before update on ch.relationship
referencing new as inserted old as deleted
for each row
begin

    set inserted.version = isnull(deleted.version,1) + 1;

    if varexists('@UOAuthAccount') = 1 then
        set inserted.author = @UOAuthAccount;
    end if;

end
;

create or replace trigger ch.tbI_relationship before insert on ch.relationship
referencing new as inserted
for each row
begin

    if varexists('@UOAuthAccount') = 1 then
        set inserted.author = @UOAuthAccount;
    end if;

end
;
