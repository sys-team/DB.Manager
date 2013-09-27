create or replace function dbm.gitFileList(
    @db ID
)
returns xml
begin
    declare @result xml;
    declare @ts datetime;
    
    set @ts = now();
    
    for lloop as ccur cursor for
    select isnull(dpbf.syncTs, '1971-07-25') as c_syncTs,
           pbf.id as c_pbf,
           dpbf.id as c_dpbf
      from dbm.gitProjectBranchFolder pbf join dbm.dbGitProjectBranchFolder dpbf on pbf.id = dpbf.gitProjectBranchFolder
     where dpbf.active = 1
       and dpbf.db = @db
    do

        set @result = xmlconcat(@result,
                                (select xmlagg(xmlelement('commit', xmlattributes(c.sha as "sha", c.summary as "summary", c.ts as "ts"),
                                                                  (select xmlagg(xmlelement('file', xmlattributes(sha as "sha", name as "name")))
                                                                     from dbm.gitFile
                                                                    where gitCommit = c.id)
                                ))
                                  from dbm.gitCommit c 
                                 where c.gitProjectBranchFolder = c_pbf
                                   and c.ts > c_syncTs));
                                   
        update dbm.dbGitProjectBranchFolder
           set syncTs = @ts
         where id = c_dpbf;

    end for;
    
    return @result;
end
;
