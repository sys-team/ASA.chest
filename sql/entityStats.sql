create or replace procedure ch.entityStats (
    @since datetime default today()
) begin
    select
        name, count(*), min(ts), max(ts)
    from
        ch.entity
    group by
        name
end