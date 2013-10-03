create or replace function dbmc.query(
    url long varchar,
    cert long varchar,
    access_token long varchar,
    command long varchar,
    sha long varchar,
    server_name long varchar default null,
    db_name long varchar default null
)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert="!cert"'
;