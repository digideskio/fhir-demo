--db:myfhir
--{{{
create SCHEMA if not EXISTS demo;
drop table if exists demo.queries;
create table demo.queries (
  name varchar not null,
  query text not null
);
insert into demo.queries(name, query) values('Insert new patient',
E'SELECT fhir.insert_resource((''{\n'
'  "resourceType": "Patient",\n'
'  "name": [{"family":["Donald'' || round(random()*10^3) || ''"]}],\n'
'  "birthDate": "'' || current_timestamp || ''"\n'
'}'')::json) as _id');

insert into demo.queries(name, query) values('Update patient',
E'SELECT fhir.update_resource((SELECT _logical_id FROM fhir.patient limit 1),\n'
'(''{\n'
'  "resourceType": "Patient",\n'
'  "name": [{"family":["Pedro'' || round(random()*10^3) || ''"]}],\n'
'  "birthDate": "'' || current_timestamp || ''"\n'
'}'')::json)');

insert into demo.queries(name, query) values('Root resource records',
E'SELECT *\n'
'FROM fhir.resource');

insert into demo.queries(name, query) values('Root patient record',
E'SELECT *\n'
'FROM fhir.patient\n'
'LIMIT 1');

insert into demo.queries(name, query) values('Patient resource',
E'SELECT data\n'
'FROM fhir.patient\n'
'LIMIT 1');

insert into demo.queries(name, query) values('Patient resource with condition',
E'SELECT data\n'
'FROM fhir.patient vp,\n'
'LATERAL (SELECT unnest(family) AS family FROM fhir.patient_name pn WHERE pn._version_id = vp._version_id) fam\n'
'WHERE fam.family ilike ''Donald%'''
'LIMIT 1');

insert into demo.queries(name, query) values('Patient name usage',
E'SELECT unnest(family) as family, count(*) as count\n'
'FROM fhir.patient_name\n'
'GROUP BY family\n'
'ORDER BY count desc, family');
--}}}


--{{{
--select resource_id, unnest(family) as family
--from fhir.patient_name
--order by resource_id;
--}}}
