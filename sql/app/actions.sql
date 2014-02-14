--db:myfhir
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

SELECT actions.resource('{"uri_args": {"type": "patient"}}'::json);
--}}}
