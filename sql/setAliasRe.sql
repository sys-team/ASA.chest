create or replace procedure ch.setAliasRe (
    @entity string,
    @aliasRe string,
    @columnsRe string,
    @isFullAlias BOOL default 0
) begin

    merge into ch.EntityAlias t using with auto name (
        select
            @entity as entity,
            @aliasRe as aliasRe,
            @columnsRe as columnsRe,
            @isFullAlias as isFullAlias
    ) as d on (1 = d.isFullAlias and d.aliasRe = t.aliasRe)
        or (d.entity = t.entity and 0 = d.isFullAlias)
    when not matched
        then insert
    when matched
        then update

end;
