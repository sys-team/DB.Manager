create or replace trigger dbm.tIU_gitCommit after insert, update on dbm.gitCommit
referencing new as inserted 
for each row
begin

    update dbm.gitProjectBranchFolder
       set syncUTs = inserted.UTs
     where id = inserted.gitProjectBranchFolder
       and isnull(syncUTs, '') < inserted.UTs;
     

end
;