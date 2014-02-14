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
FUNCTION actions.views(req json)
RETURNS json
language plv8
as $$
 return plv8.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from view." + req.uri_args.view + ' t')[0]['json']
$$;

SELECT actions.views('{"uri_args": {"view": "resource"}}'::json);
--}}}
