--db:myfhir
--{{{
create SCHEMA if not EXISTS demo;
drop table if exists demo.example_resource cascade;
create table demo.example_resource (
  file varchar primary key,
  json json not null
);

CREATE OR REPLACE VIEW
demo.example_resource_list AS (
  select file from demo.example_resource
  order by file
);
--}}}


--{{{
select * from demo.example_resource_list limit 10;
--}}}
