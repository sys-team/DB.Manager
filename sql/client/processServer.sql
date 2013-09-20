create or replace procedure dbmc.processServer(
    @server ID
)
begin
    declare @response xml;
    declare @xid GUID;
    
    -- gitFileList
    set @xid = newid();
    
    insert into dbmc.log with auto name
    select @xid as xid,
           @server as server,
           'gitfilelist' as command;
    
    set @response = dbmc.serverQuery(@server, 'gitfilelist');
    
    update dbmc.log
       set response = @response
     where xid = @xid;
    
    insert into dbmc.DBMServerGitCommit on existing update with auto name
    select (select id
              from dbmc.DBMServerGitCommit
             where sha = t.sha) as id,
          sha,
          summary,
          ts as serverTs,
          @server as DBMServer
     from openxml(@response,'/*:response/*:commit')
          with(
                sha long varchar '@sha',
                summary long varchar '@summary',
                ts long varchar '@ts'
                ) as t;
    
    insert into dbmc.DBMServerGitFile on existing update with auto name      
    select (select id
              from dbmc.DBMServerGitFile
             where sha = t.sha) as id,
           sha,
           name,
           (select id
              from dbmc.DBMServerGitCommit
             where sha = t.commitSha) as DBMServerGitCommit
      from openxml(@response,'/*:response/*:commit/*:file')
           with(
                sha long varchar '@sha',
                name long varchar '@name',
                commitSha long varchar '../@sha'
                ) as t;
    
    commit;
    
    -- gitFileData
    for lloop as ccur cursor for
    select f.id as c_id,
           f.sha as c_sha
      from dbmc.DBMServerGitFile f join dbmc.DBMServerGitCommit c on f.DBMServerGitCommit = c.id
     where c.DBMServer = @server
       and f.processed = 0
       and f.data is null
     order by c.serverTs
    do
    
        set @xid = newid();
        
        insert into dbmc.log with auto name
        select @xid as xid,
               @server as server,
               c_id as file,
               'gitfiledata' as command;
               
        set @response = dbmc.serverQuery(@server, 'gitfiledata', c_sha);
        
        update dbmc.log
           set response = @response
         where xid = @xid;
        
        update dbmc.DBMServerGitFile
           set data = (select filedata
                         from openxml(@response,'/*:response')
                              with(filedata long varchar '*:filedata'))
         where id  = c_id;
         
        commit;
        
    end for;
    
    return;
end
;