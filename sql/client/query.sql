create or replace function dbmc.query(
    url long varchar,
    cert long varchar,
    refresh_token long varchar,
    client_id long varchar,
    client_secret long varchar,
    command long varchar,
    sha long varchar
)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert="!cert"'
;