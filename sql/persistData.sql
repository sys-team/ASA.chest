create or replace procedure ch.persistData(
    @startTs datetime,
    @owner varchar(128) default 'ch'
    @entity long varchar default null
)
begin

    for lloop as ccur cursor for
    select distinct
           entity as c_entity
      from ch.entityProperty
     where (entity = @entity
        or @entity is null)
    do
        if exists(select *
                    from sys.systable)

    end for;

end
;