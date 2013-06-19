create or replace procedure ch.defineEntity (
    @name STRING,
    @properties text,
    @roles text,
    @computes text default null
) begin

    delete ch.entityProperty
        where @name = entity
    ;

    insert into ch.entityProperty on existing update with auto name
        select
            (select id from ch.entityProperty
                where entity = @name and [property] = cols.[property]
            ) as id,
            @name as entity,
            cols.*
        from openstring(
            value @properties
        ) with ([property] text) option(ROW DELIMITED BY ':') as cols
    ;

    delete ch.entityRole
        where @name = entity
    ;

    insert into ch.entityRole on existing update with auto name
        select
            (select id from ch.entityRole
                where entity = @name and [name] = cols.[name]
            ) as id,
            @name as entity,
            cols.name,
            isnull(cols.actor,cols.name) as actor
        from openstring(
            value @roles
        ) with ([name] text, [actor] text) option(ROW DELIMITED BY ':') as cols
    ;
    
    delete ch.entityCompute
        where @name = entity
    ;
    
    if @computes is not null then
        insert into ch.entityCompute on existing update with auto name
            select
                (select id from ch.entityCompute
                    where entity = @name and [name] = cols.[name]
                ) as id,
                @name as entity,
                cols.name,
                cols.type,
                cols.expression
            from openstring(
                value @computes
            ) with ([name] text, [type] text, [expression] text) option(ROW DELIMITED BY ':') as cols
        ;
    end if;
    

end;