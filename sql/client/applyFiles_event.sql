call sa_make_object('event', 'dbmc_applyFiles', 'dbmc')
;
alter event dbmc.dbmc_applyFiles
add schedule dbmc_applyFiles
between '8:00AM'  and '19:59PM'
every 60 minutes on  ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
handler
begin

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;

    call dbmc.applyFiles();

end
;