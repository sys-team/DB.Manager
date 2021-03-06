create or replace function dbmc.serverQuery(
    @server ID,
    @command long varchar,
    @sha long varchar default null
)
returns xml
begin
    declare @url long varchar;
    declare @cert long varchar;
    declare @UOAuthClient long varchar;
    declare @UOAuthClientSecret long varchar;
    declare @UOAuthRefreshToken long varchar;
    declare @accessToken long varchar;
    declare @response long varchar;
    declare @roles xml; 
    
    select url,
           cert,
           UOAuthClient,
           UOAuthClientSecret,
           UOAuthRefreshToken
      into @url, @cert, @UOAuthClient, @UOAuthClientSecret, @UOAuthRefreshToken
      from dbmc.DBMServer
     where id = @server;

    if @url is null then
        raiserror 55555 'Wrong server url';
        return null;
    end if;
    
    set @roles = uac.UOAuthRefreshToken(@UOAuthRefreshToken, @UOAuthClient, @UOAuthClientSecret);

    set @accessToken = (select access_token
                          from openxml(@roles, '/*:response')
                                with(access_token long varchar '*:access-token'));
                                
    
    set @response = dbmc.query(
                                @url,
                                @cert,
                                @accessToken,
                                @command,
                                @sha,
                                @@servername,
                                db_name()
                            );
                            
    return @response;
end
;