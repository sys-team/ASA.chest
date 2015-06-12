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
    @name string
) returns timestamp begin

    declare @result timestamp;

    set @result = (
        select persistTs from ch.persistEntityData
        where entity = @name
    );

    return @result;

end;
