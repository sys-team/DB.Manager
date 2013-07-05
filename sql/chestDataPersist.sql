create or replace procedure dbm.chestDataPersist()
begin
    declare @ts datetime;
    declare @ets datetime;
    
    set @ts = now();
    
    -- dbm.gitCommit
    set @ets = isnull((select persistTs
                         from ch.persistEntityData
                        where entity = 'gitClient.commit'), '1971-07-25');
                        
    insert into dbm.gitCommit on existing update with auto name
    select (select id
                  from dbm.gitCommit
               where sha = t.code) as id,
            t.code as sha,
            t.[message] as summary,
            t.[date] as UTs,
           (select pbf.id
              from dbm.gitProjectBranchFolder pbf join dbm.gitProjectBranch pb on pbf.gitProjectBranch = pb.id
                                                  join dbm.gitProject p on pb.gitProject = p.id
                                                  join dbm.gitUser u on p.gitUser = u.id
             where pbf.name = t.path
               and pb.name = t.branch
               and p.name = t.repo
               and u.name = t.owner) as gitProjectBranchFolder
       from ch.entity e outer apply (select *
                                       from openxml(e.xmlData,'/*')
                                            with(
                                                code long varchar '@code', 
                                                [date] long varchar '*[@name="date"]',
                                                [message] long varchar '*[@name="message"]',
                                                owner long varchar '*[@name="owner"]',
                                                repo long varchar '*[@name="repo"]',
                                                path long varchar '*[@name="path"]',
                                                branch long varchar '*[@name="branch"]'
                                            )) as t
      where e.name = 'gitclient.commit'
        and e.ts >= @ets
      order by e.ts;
        
    insert into ch.persistEntityData on existing update with auto name
    select (select id
              from ch.persistEntityData
             where entity = 'gitClient.commit') as id,
           @ts as persistTs,
          'gitClient.commit' as entity;
                            
    -- dbm.gitFile
    set @ets = isnull((select persistTs
                         from ch.persistEntityData
                        where entity = 'gitClient.file'), '1971-07-25');
                        
    insert into dbm.gitFile on existing update with auto name
    select (select id
              from dbm.gitFile
             where sha = t.code) as id,
            t.code as sha,
            t.filename as name,
            t.filedata as data,
            (select id
               from dbm.gitCommit
              where sha = t.commitCode) as gitCommit
       from ch.entity e outer apply(select *
                                      from openxml(e.xmlData,'/*')
                                           with(
                                                code long varchar '@code', 
                                                filename long varchar '*[@name="filename"]',
                                                filedata long varchar '*[@name="filedata"]',
                                                commitCode long varchar '*:d[@name="gitClient.commit"]/@code'
                                           )) as t
      where e.name = 'gitClient.file'
        and e.ts >= @ets;
        
    insert into ch.persistEntityData on existing update with auto name
    select (select id
              from ch.persistEntityData
             where entity = 'gitClient.file') as id,
           @ts as persistTs,
          'gitClient.file' as entity;
        
        
end
;