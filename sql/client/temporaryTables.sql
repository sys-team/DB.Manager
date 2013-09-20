create global temporary table if not exists dbmc.applyLog (

    fileId ID,
    result long varchar,    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;

create global temporary table if not exists dbmc.log (

    server ID,
    file ID,
    command varchar(255),
    response STRING,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;