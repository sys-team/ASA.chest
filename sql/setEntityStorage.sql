create or replace procedure ch.setEntityStorage (
    @nameRe string,
    @ord int,
    @storage string
) begin

    merge into ch.EntityStorage using with auto name (
        select
            @nameRe as nameRe,
            @ord as ord,
            @storage as storage
    ) as d on d.nameRe = EntityStorage.nameRe
    when not matched
        then insert
    when matched and (EntityStorage.ord <> d.ord or EntityStorage.storage <> d.storage)
        then update

end;
