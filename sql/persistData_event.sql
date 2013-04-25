sa_make_object 'event', 'persistData', 'ch'
;
alter event ch.persistData
add schedule ch_persistData
between '0:00AM'  and '23:59PM'
every 10 minutes on  ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
handler
begin

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;
    
    call  ch.persistData('cht');

    exception  
    when others then
        
        call util.errorHandler('ch.persistData', @SQLSTATE, errormsg());
        
        rollback;
        
end