create or replace procedure dbmc.applyFiles()
begin
    declare @file ID;
    declare @error long varchar;
    declare @sqlstate long varchar;
    declare @xid GUID;
    
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
        set @xid = newid();
        set @file = c_id;
        
        insert into dbmc.applyLog with auto name
        select @xid as xid,
               c_id as fileId;
            
        --message 'dbmc.applyFiles c_data = ', c_data;
        --execute immediate 'begin ' + c_data + ' end';
        execute immediate c_data;
        
        update dbmc.DBMServerGitFile
           set processed = 1
         where id = c_id;
         
        update dbmc.applyLog
           set result = 'ok'
         where xid = @xid;
         
        commit;
        
    end for;
    
    set @file = null;
    
    -- update forbidden
    update dbmc.DBMServerGitFile
       set processed = 2
     where processed = 0
       and (substr(name, locate(name,'.',-1) +1) not in (select ext from #allowedExt)
        or substr(name, locate(name,'/',-1) +1) in (select name from #forbiddenName));

    return;
    
    exception  
        when others then
        
            set @error = errormsg();
            set @sqlstate = SQLSTATE;
            
            update dbmc.DBMServerGitFile
               set processed = -1
            where id = @file;
            
            commit;
                
            call util.errorHandler('dbmc.applyFiles', @sqlstate, @error);
            
            update dbmc.applyLog
               set result = @error
             where xid = @xid;
        
end
;