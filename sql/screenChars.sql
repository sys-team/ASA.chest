create or replace function ch.screenChars(
    @data STRING
) returns STRING
begin
    declare @result STRING;
    declare @pos integer;
    declare @tmp STRING;

    set @result = @data;

    set @pos = locate(@result, char(26));

    if @pos <> 0 then

        set @result = left(@result, @pos -1)
            + substring(@result, @pos + 3);

    end if;

    -- Знак рубля
    set @pos = locate(@result, 0xe282bd);

    if @pos <> 0 then

        set @result = left(@result, @pos -1)
            'руб' + substring(@result, @pos + 3);

    end if;

    -- tehnique patch
    set @Result =  replace(@result, '&#60;/string>', 'руб</string>');


    set @tmp = regexp_substr(@result,'&#[0-9]*;', 0, 1);

    while (@tmp is not null) loop

        set @result = replace(@result, @tmp, '');
        set @tmp = regexp_substr(@result, '&#[0-9]*;' , 0, 1);

    end loop;

    return @result;

end
;
