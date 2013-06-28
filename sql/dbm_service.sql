sa_make_object 'service', 'dbm'
;
alter service dbm
type 'raw' 
authorization off user "dbm"
url on
as call util.xml_for_http(dbm.dbm(:url));