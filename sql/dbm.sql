create or replace function dbm.dbm(
    @url long varchar,
    @accessToken long varchar default http_variable('access_token'),
    @command long varchar default http_variable('command'),
    @sha long varchar default http_variable('sha')
)
returns xml
begin
    declare @xid GUID;
    declare @error long varchar;
    declare @response xml;
    declare @roles xml;

    set @xid = newid();
    
    insert into dbm.log with auto name
    select @xid as xid;
    
    // Auth
    set @roles = uac.UOAuthAuthorize(@accessToken);
    // roles check
    if varexists('@db') = 0 then create variable @db integer end if;
    
    set @db = (select db.id
                 from dbm.db db join (select code,
                                             data
                                        from openxml(@roles, '/*:response/*:roles/*:role')
                                             with(code STRING '*:code', data STRING '*:data')) as t on t.data =  db.code
                where t.code = 'dbmc');
                
    if @db is null then
        set @response = dbm.responseRootElement(xmlelement('error', 'Not authorized'));
        
        update dbm.log
           set response = @response
         where xid = @xid;
         
        return @response;
    end if;
    
    case @command
        when 'gitfilelist' then
            set @response = dbm.gitFileList(@db);
        when 'gitfiledata' then
            set @response = dbm.GitFileData(@sha);
        else
            set @response = xmlelement('error', 'Unknown command');
    end case;    
    
    //                
    set @response = dbm.responseRootElement(@response);
    
    update dbm.log
       set response = @response
     where xid = @xid;

    return @response

    exception  
        when others then
            set @error = errormsg();
            set @response = dbm.responseRootElement(xmlelement('error', @error));
            
            update dbm.log
               set response = @response
            where xid = @xid;
            
            return @response;

end
;