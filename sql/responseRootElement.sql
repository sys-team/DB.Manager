create or replace function dbm.responseRootElement(
    @response xml
)
returns xml
begin
    declare @result xml;
    
    set @result = xmlelement('response', xmlattributes('https://github.com/sys-team/DB.Manager' as "xmlns",now() as "ts"), @response);
    
    return @result;
end
;