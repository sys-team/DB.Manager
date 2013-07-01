call sa_make_object('event', 'dbmc_applyFiles', 'dbmc')
;
alter event dbmc.dbmc_applyFiles
add schedule dbmc_applyFiles
between '8:00AM'  and '19:59PM'
every 60 minutes on  ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
handler
begin
    declare @error long varchar;

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;
    
    if varexists('@xid') = 0 then create variable @xid GUID; end if;

    call dbmc.applyFiles();

    exception  
    when others then
        set @error = errormsg();
        call util.errorHandler('dbmc.applyFiles', SQLSTATE, @error);
        
        update dbmc.applyLog
           set result = @error
         where xid = @xid;
        
        rollback;
end
;