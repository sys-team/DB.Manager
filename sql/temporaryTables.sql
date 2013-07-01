create global temporary table if not exists dbm.gitLog(
    client_id varchar(256),
    client_secret varchar(256),
    refresh_token varchar(256),
    git_user varchar(256),
    git_repo varchar(256),
    git_branch varchar(256),
    git_path varchar(256),
    git_ts varchar(256),
    git_token varchar(256),

    response long varchar,    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;


create global temporary table if not exists dbm.log(

    httpBody long varchar default http_body(),
    callerIP varchar(128) default connection_property('ClientNodeAddress'),
    
    response xml,    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;