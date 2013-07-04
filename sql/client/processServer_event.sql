call sa_make_object('event', 'dbmc_processServer', 'dbmc')
;
alter event dbmc.dbmc_processServer
add schedule dbmc_processServer
between '8:00AM'  and '19:59PM'
every 60 minutes on  ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
handler
begin
    declare @error long varchar;

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;
    
    for lloop as ccur cursor for
    select id as c_id
      from dbmc.DBMServer
     where active = 1
    do
        call dbmc.processServer(c_id);    
    end for;

    exception  
    when others then
        set @error = errormsg();
        call util.errorHandler('dbmc.processServer', SQLSTATE, @error);
        
        rollback;
end
;