grant connect to dbm;
grant dba to dbm;

create table dbm.gitUser(

    name varchar(256) not null unique,
    accessToken varchar(256),
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitUser is 'Github user'
;

create table dbm.gitProject (

    name varchar(256) not null unique,
    accessToken varchar(256),
    
    not null foreign key(gitUser) references dbm.gitUser,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitProject is 'Github ptoject'
;


create table dbm.gitProjectBranch (

    name varchar(256) not null default 'master',
    gitProject ID,
    active integer default 1,
    
    not null foreign key(gitProject) references dbm.gitProject,
    
    unique(gitProject, name),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitProjectBranch is 'Github ptoject branch'
;

create table dbm.gitProjectBranchFolder (

    name varchar(256) not null default 'sql',
    gitProjectBranch ID,
    syncUTs varchar(64),

    not null foreign key(gitProjectBranch) references dbm.gitProjectBranch,
    
    unique(gitProjectBranch, name),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitProjectBranchFolder is 'Github ptoject branch folder'
;

create table dbm.gitCommit (

    sha varchar(256) not null unique,
    summary long varchar,
    UTs varchar(64),
    
    not null foreign key(gitProjectBranchFolder) references dbm.gitProjectBranchFolder,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitCommit is 'Github project branch commit'
;

create table dbm.gitFile(

    sha varchar(256) not null unique,
    name varchar(256) not null,
    
    data long varchar,

    not null foreign key(gitCommit) references dbm.gitCommit,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.gitFile is 'Github file'
;

create table dbm.db(

    name varchar(256) not null unique,
    code varchar(256) not null unique,
    serverName varchar(256) not null,
    dbName varchar(256) not null,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.db is 'Database-client'
;

create table dbm.dbGitProjectBranchFolder(

    active integer default 1,
    syncTs datetime,
    
    db ID,
    gitProjectBranchFolder ID,

    not null foreign key(db) references dbm.db,
    not null foreign key(gitProjectBranchFolder) references dbm.gitProjectBranchFolder,

    unique(db, gitProjectBranchFolder),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id) 
)
;
comment on table dbm.dbGitProjectBranchFolder is 'Database-client branch subscription'
;

