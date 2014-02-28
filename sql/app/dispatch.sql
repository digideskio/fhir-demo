--db:myfhir
--{{{
CREATE SCHEMA IF NOT EXISTS app;

DROP TABLE IF EXISTS app.routes;

CREATE TABLE app.routes (
  id serial primary key,
  method varchar,
  pattern varchar,
  handler varchar
);

INSERT INTO app.routes
(method, pattern, handler)
VALUES
('GET', '/data/about', 'about'),
('GET', '/data/view', 'view'),
('GET', '/data/show', 'show'),
('GET', '/data/tables', 'get_tables'),
('GET', '/data/delete', 'delete_resource'),
('PUT', '/data/resource', 'update_resource'),
('GET', '/data/details', 'details'),
('GET', '/data/query', 'query'),
('GET', '/data/resource', 'resource'),
('GET', '/data/demo', 'demo'),
('GET', '/data/demo/by_attr', 'demo_by_attr'),
('POST', '/data/resource/create', 'create_resource')
;
--}}}
--{{{
CREATE SCHEMA IF NOT EXISTS lib;
CREATE EXTENSION IF NOT EXISTS plv8;

DROP FUNCTION IF EXISTS lib.dispatch(json);

CREATE or REPLACE
FUNCTION lib.dispatch(req json)
RETURNS json
language plv8
as $$
  if(!req){
    return {error: 'Empty req'}
  }
  if(req.uri_args && req.uri_args._echo){ return req; }

  plv8.elog(NOTICE, JSON.stringify(req))
  route = plv8
  .execute("SELECT * FROM app.routes where upper(method) = upper($1) AND pattern = $2 limit 1",
    [req.meth, req.uri])[0]

  if(route){
    try {
      return plv8.execute("SELECT actions." + route.handler + "($1) as res",[req])[0]['res']
    }catch(e){
      return {error: e.toString()};
    }
  } else {
    return {error: 'missing route', req: req }
  }
$$;

--select lib.dispatch('{"a":1}'::json);
--select lib.dispatch('{"uri_args": {"echo":1}}'::json);
--select lib.dispatch('{"uri": "/data/about"}'::json);
--select lib.dispatch(NULL);
--}}}
