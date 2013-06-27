create or replace procedure ch.triggerEvent()
begin
    declare @sql long varchar;

    for lloop as ccur cursor for 
    select event_name as c_name
      from sys.sysevent
     where event_name like '%chestDataPersist'
       and enabled = 'Y'
    do
        set @sql  ='trigger event ' + c_name;
        execute immediate @sql;
    end for;

end
;