grant connect to dbmc;
grant dba to dbmc;

create table dbmc.DBMServer(

    name varchar(256) not null unique,
    active integer default 1,
    
    url long varchar,
    cert long varchar,
    UOAuthClient varchar(256),
    UOAuthClientSecret varchar(256),
    UOAuthRefreshToken varchar(256),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbmc.DBMServer is 'DB.Manager server'
;

create table dbmc.DBMServerGitCommit (
    summary long varchar,
    sha varchar(256) not null unique,
    serverTs datetime,

    not null foreign key(DBMServer) references dbmc.DBMServer,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbmc.DBMServerGitCommit is 'Git-commit DB.Manager server'
;

create table dbmc.DBMServerGitFile(

    name varchar(256) not null,
    sha varchar(256) not null unique,
    
    processed integer default 0,
    
    not null foreign key(DBMServerGitCommit) references dbmc.DBMServerGitCommit,
    
    data long varchar,    

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbmc.DBMServerGitFile is 'Git-file received from DB.Manager server'
;