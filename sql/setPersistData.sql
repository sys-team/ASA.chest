create or replace procedure ch.setPersistData (
    @name string,
    @ts timestamp
) begin

    merge into ch.persistEntityData t using with auto name (
        select
            @name as entity,
            @ts as persistTs
    ) as d on d.entity = t.entity
    when not matched
        then insert
    when matched
        then update

end;


create or replace function ch.getPersistData (
    @name string,
    @startDate timestamp default '2000-01-01'
) returns timestamp begin

    declare @result timestamp;

    set @result = (
        select persistTs from ch.persistEntityData
        where entity = @name
    );

    return isnull (@result,@startDate);

end;

create or replace function ch.getSetPersistData (
    @name string,
    @ts timestamp default now()
) returns timestamp begin

    declare @result timestamp;

    set @result = ch.getPersistData (@name);
    
    call ch.setPersistData(@name,@ts);

    return @result;

end;
