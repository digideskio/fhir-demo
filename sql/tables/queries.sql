--db:myfhir
--{{{
create SCHEMA if not EXISTS demo;
drop table if exists demo.queries;
create table demo.queries (
  query text not null
);
insert into demo.queries(query) values('select * from fhir.resource order by id');
insert into demo.queries(query) values('select * from fhir.patient order by id');
insert into demo.queries(query) values('select * from fhir.view_patient order by id');
insert into demo.queries(query) values('select * from fhir.view_patient where id in (select resource_id from fhir.patient_name where ''MINT_TEST'' = any(family))');
--}}}


--{{{
select * from demo.queries limit 10;
--}}}
