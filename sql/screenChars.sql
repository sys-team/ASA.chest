create or replace function ch.screenChars(
    @data STRING
) returns STRING
begin
    declare @result STRING;
    declare @pos integer;

    set @pos = locate(@data, char(26));

    if @pos <> 0 then

        set @result = left(@data, @pos -1)
            + substring(@data, @pos + 3);

    end if;

    return @result;

end
;
