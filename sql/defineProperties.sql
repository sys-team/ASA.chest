create or replace procedure ch.defineProperties (
    @data text
) begin

    insert into ch.property on existing update with auto name
        select (select id from ch.property where name = cols.name) as id, *
        from openstring(
            value @data
        ) with (
            [name] text, [type] text, [initial] text
        ) option(ROW DELIMITED BY ':') as cols
    ;

end;