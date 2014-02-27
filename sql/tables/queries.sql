--db:myfhir
--{{{
create SCHEMA if not EXISTS demo;
drop table if exists demo.queries;
create table demo.queries (
  name varchar not null,
  query text not null
);
insert into demo.queries(name, query) values('All resources', 'select * from fhir.resource order by id');
insert into demo.queries(name, query) values('Patients', 'select * from fhir.patient order by id');
insert into demo.queries(name, query) values('Patient resources', 'select * from fhir.view_patient order by id');
insert into demo.queries(name, query) values('Vasiliy', 'select * from fhir.view_patient where id in (select resource_id from fhir.patient_name where ''MINT_TEST'' = any(family))');
--}}}


--{{{
select * from demo.queries limit 10;
--}}}
