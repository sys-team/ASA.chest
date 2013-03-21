create or replace function ch.remoteColumnName(
    @column long varchar
)
returns long varchar
begin
    case @column
        when 'ts' then
            set @column = 'remoteTs'
        when 'cts' then
            set @column = 'remoteCts'
        when 'id' then
            set @column = 'remoteId'
        when 'version' then
            set @column = 'remoteVersion'
        when 'lastUser' then
            set @column = 'remoteLastUser'
    end case;

    return @column;
end
;