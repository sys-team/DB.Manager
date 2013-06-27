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
    declare @xid GUID;

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
        set @xid = newid(); 

        insert into dbm.gitLog with auto name
        select @xid as xid,
               @UOAClient as client_id,
               @UOAClientSecret as client_secret,
               @UOARefreshToken as refresh_token,
               c_gitUser as git_user,
               c_gitProject as git_repo,
               c_gitBranch as git_branch,
               c_gitPath as git_path,
               c_syncUTs as git_ts,
               c_gitToken as git_token;

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
         
        update dbm.gitLog
           set response = @response
         where xid = @xid;
         
        commit;
    
    end for;

    return;
end
;