--db:fhir
--{{{
CREATE SCHEMA IF NOT EXISTS actions;
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.about(req json)
RETURNS json
language plv8
as $$
 return {message: 'here is about page', request: req}
$$;
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.view(req json)
RETURNS json
language plv8
as $$
 return plv8.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from view." + req.uri_args.view + ' t')[0]['json']
$$;

SELECT actions.view('{"uri_args": {"view": "resource"}}'::json);
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.query(req json)
RETURNS json
language plv8
as $$
 var sql =  "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from (" + req.uri_args.q + ") t"
 plv8.elog(NOTICE, sql)
 return plv8.execute(sql)[0]['json']
$$;

SELECT actions.query('{"uri_args": {"q": "select * from fhir.patient"}}'::json);
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.resource(req json)
RETURNS json
language plv8
as $$
 var sql =  "SELECT array_to_json(array_agg(t.json))::varchar as json from fhir.view_" + req.uri_args.type + ' t limit 100'
 plv8.elog(NOTICE, sql)
 return plv8.execute(sql)[0]['json'];
$$;

--SELECT actions.resource('{"uri_args": {"type": "patient"}}'::json);
--}}}

--{{{
DROP FUNCTION actions.create_resource(json);
CREATE OR REPLACE
FUNCTION actions.create_resource(body json)
RETURNS json
language plpgsql AS $$
BEGIN
  RETURN row_to_json(ROW(fhir.insert_resource(body->'request_body')));
END
$$;

--SELECT actions.create_resource('{"request_body": {"resourceType": "Patient"}, "uri_args": {"type": "patient"}}'::json);
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.demo(req json)
RETURNS json
language plv8
as $$
 return plv8.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from demo." + req.uri_args.rel + ' t')[0]['json']
$$;

CREATE or REPLACE
FUNCTION actions.demo_by_attr(req json)
RETURNS json
language plv8
as $$
 var args = req.uri_args;
 var sql = "SELECT row_to_json(t.*)::varchar as json from demo." + req.uri_args.rel + ' t where ' + args.col + '= $1 limit 1'
 plv8.elog(NOTICE, sql)
 return (plv8.execute(sql,[args.val])[0] || {json: {"error": 'nothing found'}})['json']
$$;
--}}}
--{{{
--select * from demo.example_resource_list limit 1;
--SELECT actions.demo_by_attr('{"uri_args": {"rel": "example_resource", "col": "file", "val": "address-use.json"}}'::json);
--}}}

--}}}
CREATE SCHEMA IF NOT EXISTS view;
CREATE OR REPLACE
VIEW view.resource AS (
  select unnest(path) as title from meta.resource_elements
  where array_length(path,1) = 1
  order by title
);
--}}}
