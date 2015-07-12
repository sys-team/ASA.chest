create or replace procedure ch.setEntityRole (
    @entity string,
    @actor string,
    @name string
) begin

    merge into ch.entityRole using with auto name (
        select
            @entity as entity,
            @actor as actor,
            @name as name
    ) as d on d.entity = entityRole.entity and d.name = entityRole.name
    when not matched
        then insert
    when matched
        then update

end;
