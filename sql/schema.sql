--db:myfhir
--{{{
create extension if not exists plv8;
DROP FUNCTION web_rel(varchar);
CREATE or REPLACE
FUNCTION web_rel(q varchar)
RETURNS varchar
language plpythonu
as $$
  return plpy.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from fhir." + q + ' t')[0]['json']
$$;

select web_rel('patient');
--}}}

--{{{

CREATE or REPLACE
FUNCTION web_res(q varchar)
RETURNS varchar
language plpythonu
as $$
  return plpy.execute("SELECT array_to_json(array_agg(t.json))::varchar as json from fhir.view_" + q + ' t')[0]['json'];
$$;

select web_res('patient');
--}}}

--{{{

CREATE SCHEMA IF NOT EXISTS view;
CREATE OR REPLACE
VIEW view.resource AS (
  select unnest(path) as title from meta.resource_elements
  where array_length(path,1) = 1
  order by title
);

CREATE or REPLACE
FUNCTION web_view(q varchar)
RETURNS varchar
language plpythonu
as $$
  return plpy.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from view." + q + ' t')[0]['json']
$$;

select web_view('resource');
--}}}

--{{{

DROP FUNCTION web_post(varchar);
CREATE OR REPLACE
FUNCTION web_post(body json)
RETURNS varchar
language plpgsql AS $$
BEGIN
  RETURN fhir.insert_resource(body) as resource_id;
END
$$;

select web_post('{"resourceType":"Encounter"}');
--}}}
--{{{
\dt meta.*

select unnest(path) as title, * from meta.resource_elements
where array_length(path,1) = 1;
--}}}
