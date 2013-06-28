create or replace function dbm.GitFileData(
    @sha long varchar
)
returns xml
begin
    declare @result xml;

    set @result = (select xmlelement('filedata', xmlattributes(sha as "sha"),
                                               --'<![CDATA[' +
                                               data
                                               --+ ']]>'
                                               )
                     from dbm.gitFile
                    where sha = @sha);    
    
    return @result;
end
;