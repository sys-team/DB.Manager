call sa_make_object('event', 'dbm_chestDataPersist', 'dbm')
;
alter event dbm.dbm_chestDataPersist
handler
begin

    if EVENT_PARAMETER('NumActive') <> '1' then 
        return;
    end if;

    call dbm.chestDataPersist();

    exception  
    when others then
        call util.errorHandler('ch.dbm_chestDataPersist', @SQLSTATE, errormsg());
        rollback;
end
;