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
    declare @response long varchar;
    
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
    
    set @response = dbmc.query(
                                @url,
                                @cert,
                                @UOAuthRefreshToken,
                                @UOAuthClient,
                                @UOAuthClientSecret,
                                @command,
                                @sha
                            );
                            
    return @response;
end
;