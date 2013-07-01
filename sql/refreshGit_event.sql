sa_make_object 'event', 'refreshGit', 'dbm'
;
alter event dbm.refreshGit
add schedule dbm_refreshGit
between '8:00AM'  and '19:59PM'
every 360 minutes on  ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
handler
begin

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;
    
    call dbm.refreshGitProject();

    exception  
    when others then   
        call util.errorHandler('dbm.refreshGit', SQLSTATE, errormsg());
        rollback;
        
end