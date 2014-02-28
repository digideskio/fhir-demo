drop schema if exists test cascade;
create schema test;

CREATE OR REPLACE VIEW
test.columns AS (
  SELECT
    c.table_name,
    c.column_name,
    c.ordinal_position,
    CASE
      WHEN c.data_type = 'ARRAY' THEN e.data_type || '[]'
      WHEN c.data_type = 'USER-DEFINED' THEN c.udt_name
      ELSE c.data_type
    END AS data_type
  FROM information_schema.columns c
    LEFT JOIN information_schema.element_types e
      ON c.dtd_identifier = e.collection_type_identifier and
         c.table_schema = e.object_schema AND
         c.table_name = e.object_name
  WHERE c.table_schema = 'fhir'
);

CREATE
VIEW test.resource_tables as (
  SELECT
    path,
    path[1] as resource_name,
    table_name(path) as table_name,
    resource_table_name(path) as resource_table_name,
    parent_table_name(path) as parent_table_name,
    case
      when array_length(path, 1) > 1 then 'resource_component'
      else 'resource'
    end as base_table,
    coalesce((
      SELECT array_agg(column_ddl)
        FROM meta.resource_columns rc
       WHERE array_pop(rc.path) = e.path
    ), ARRAY[]::varchar[]) as columns
  FROM meta.compound_resource_elements e
  UNION
  SELECT
    path,
    path[1],
    table_name(path) as table_name,
    resource_table_name(path) as resource_table_name,
    parent_table_name(path) as parent_table_name,
    base_table,
    array[]::varchar[] as columns
  FROM meta.expanded_with_dt_resource_elements
);

create type test.column_desc as (column_name varchar, data_type varchar);
create type test.resource_desc as (table_name varchar, columns json);

create view test.expanded_resource_tables as
  select
    rt.path,
    rt.resource_name,
    rt.table_name,
    array_to_json(array_agg((c.column_name, c.data_type)::test.column_desc order by c.ordinal_position)) as columns
  from test.resource_tables rt
  join test.columns c on c.table_name = rt.table_name
  group by rt.path, rt.resource_name, rt.table_name;

create view test.resource_description as
  select resource_name, array_to_json(array_agg((table_name, columns)::test.resource_desc)) as description from test.expanded_resource_tables
  group by resource_name;
