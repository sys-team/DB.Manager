create or replace procedure dbmc.applyFiles()
begin
    
    declare local temporary table
    #forbiddenName(name long varchar unique)
    on commit preserve rows;
    
    declare local temporary table
    #allowedExt(ext long varchar unique)
    on commit preserve rows;
    
    insert into #forbiddenName values('_tables.sql');
    insert into #forbiddenName values('temporaryTables.sql');
    insert into #forbiddenName values('_windows_deploy.sql');
    
    insert into #allowedExt values('sql');
    
    for lloop as ccur cursor for
    select f.id as c_id,
           f.data as c_data, 
           f.name as c_name,
           substr(f.name, locate(f.name,'.',-1) +1) as c_ext,
           substr(f.name, locate(f.name,'/',-1) +1) as c_shortName
      from dbmc.DBMServerGitFile f join dbmc.DBMServerGitCommit c on f.DBMServerGitCommit = c.id
     where c_shortName not in (select name from #forbiddenName)
       and c_ext in (select ext from #allowedExt)
       and f.processed = 0
       and f.data is not null
       and not exists (select *
                         from dbmc.DBMServerGitFile
                        where DBMServerGitCommit = c.id
                           and data is null)
     order by c.serverTs
    do
            
        message 'dbmc.applyFiles c_data = ', c_data;
        execute immediate 'begin ' + c_data + ' end';
        
        update dbmc.DBMServerGitFile
           set processed = 1
         where id = c_id;
         
        commit;
        
    end for;

    return;
end
;