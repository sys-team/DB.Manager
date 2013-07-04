create or replace function dbmc.query(
    url long varchar,
    cert long varchar,
    access_token long varchar,
    command long varchar,
    sha long varchar
)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert="!cert"'
;