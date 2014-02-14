--db:myfhir
--{{{
CREATE SCHEMA IF NOT EXISTS lib;
CREATE EXTENSION IF NOT EXISTS plv8;

DROP FUNCTION lib.dispatch(json);

CREATE or REPLACE
FUNCTION lib.dispatch(req json)
RETURNS json
language plv8
as $$
  if(!req){
    return {error: 'Empty req'}
  }
  if(req.uri_args && req.uri_args._echo){ return req; }

  route = plv8
  .execute("SELECT * FROM app.routes where pattern = $1 limit 1",
    [req.uri])[0]

  if(route){
    try {
      return plv8.execute("SELECT actions." + route.handler + "($1) as res",[req])[0]['res']
    }catch(e){
      return e;
    }
  } else {
    return {error: 'missing route', req: req }
  }
$$;

select lib.dispatch('{"a":1}'::json);
select lib.dispatch('{"uri_args": {"echo":1}}'::json);
select lib.dispatch('{"uri": "/data/about"}'::json);
select lib.dispatch(NULL);
--}}}
