create global temporary table if not exists dbmc.applyLog (

    fileId ID,
    result long varchar,    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;