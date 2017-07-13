create or replace trigger ch.tbU_entity before update on ch.entity
referencing new as inserted old as deleted
for each row
begin

    if inserted.status <> 0
    and inserted.xmlData <> deleted.xmlData then

        set inserted.status = 0;

    end if;

end
;
