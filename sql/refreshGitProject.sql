create or replace procedure dbm.refreshGitProject(
    @gitUser long varchar default null,
    @gitProject long varchar default null
)
begin
    declare @gitClientUrl long varchar;
    declare @gitClientCert long varchar;
    declare @UOAClient long varchar;
    declare @UOAClientSecret long varchar;
    declare @UOARefreshToken long varchar;
    declare @response long varchar;
    declare @uts long varchar;
     
    set @uts = replace(left(cast( current utc timestamp as varchar(32)), 19),' ','T') +'Z';
    
    set @gitClientUrl = util.getUserOption('gitClientUrl');
    set @gitClientCert = util.getUserOption('gitClientCert');
    set @UOAClient = util.getUserOption('UOAClient');
    set @UOAClientSecret = util.getUserOption('UOAClientSecret');
    set @UOARefreshToken = util.getUserOption('UOARefreshToken');
    
    for lloop as ccur cursor for
    select u.name as c_gitUser,
           coalesce(p.accessToken, u.accessToken) as c_gitToken,
           p.name as c_gitProject,
           pb.name as c_gitBranch,
           pbf.name as c_gitPath,
           pbf.syncUTs as c_syncUTs,
           pbf.id as c_pbf_id
      from dbm.gitUser u join dbm.gitProject p on u.id = p.gitUser
                         join dbm.gitProjectBranch pb on pb.gitProject = p.id
                         join dbm.gitProjectBranchFolder pbf on pbf.gitProjectBranch = pb.id
     where pb.active = 1
       and (u.name = @gitUser
        or @gitUser is null)
       and (p.name = @gitProject
        or @gitProject is null)
    do

        set @response = dbm.gitQuery (
            @gitClientUrl,
            @gitClientCert,
            @UOAClient,
            @UOAClientSecret,
            @UOARefreshToken,
            c_gitUser,
            c_gitProject,
            c_gitBranch,
            c_gitPath,
            isnull(c_syncUTs,''),
            c_gitToken
        );
        
        update dbm.gitProjectBranchFolder
           set syncUTs = @uts
         where id = c_pbf_id;
         
        commit;
    
    end for;

    return;
end
;