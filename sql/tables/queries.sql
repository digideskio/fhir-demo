--db:myfhir
--{{{
create SCHEMA if not EXISTS demo;
drop table if exists demo.queries;
create table demo.queries (
  name varchar not null,
  query text not null
);
insert into demo.queries(name, query) values('Root resource records',
E'SELECT *\n'
'FROM fhir.resource');
insert into demo.queries(name, query) values('Root patient record',
E'SELECT *\n'
'FROM fhir.patient\n'
'LIMIT 1');
insert into demo.queries(name, query) values('Patient resource',
E'SELECT *\n'
'FROM fhir.view_patient\n'
'LIMIT 1');
insert into demo.queries(name, query) values('Patient resource with condition',
E'SELECT *\n'
'FROM fhir.view_patient\n'
'WHERE id in (select resource_id from fhir.patient_name where ''MINT_TEST'' = any(family))\n'
'LIMIT 1');
insert into demo.queries(name, query) values('Patient name usage',
E'SELECT unnest(family) as family, count(*) as count\n'
'FROM fhir.patient_name\n'
'GROUP BY family\n'
'ORDER BY count desc, family');
--}}}


--{{{
select resource_id, unnest(family) as family
from fhir.patient_name
order by resource_id;
--}}}
