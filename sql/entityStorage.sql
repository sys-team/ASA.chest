create or replace function ch.entityStorage (
  @entity STRING
) returns STRING
begin

  declare @result string;

  set @result = (
    select top 1 storage
    from ch.entityStorage
    where @entity regexp nameRe
    order by ord desc
  );

  return @result;

end;
