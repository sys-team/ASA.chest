call sa_make_object('service', 'chest')
;
alter service chest
TYPE 'RAW' 
authorization off user "ch"
--authorization on
url on
as call util.xml_for_http(ch.chest(:url));