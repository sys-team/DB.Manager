sa_make_object 'event', 'dbm_chestDataPersist', 'dbm'
;
alter event dbm.dbm_chestDataPersist
handler
begin

    call dbm.chestDataPersist();

    exception  
    when others then
        call util.errorHandler('ch.dbm_chestDataPersist', @SQLSTATE, errormsg());
        rollback;
end
;