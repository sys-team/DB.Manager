create or replace function dbm.gitQuery (
    url long varchar,
    cert long varchar,
    client_id long varchar,
    client_secret long varchar,
    refresh_token long varchar,
    git_user long varchar,
    git_repo long varchar,
    git_branch long varchar,
    git_path long varchar,
    git_ts long varchar,
    git_token long varchar
)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert="!cert"'
;