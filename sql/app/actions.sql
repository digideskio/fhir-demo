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
  return plv8.execute( "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from view." + req.uri_args.view + ' t')[0]['json'];
$$;

--SELECT actions.view('{"uri_args": {"view": "resource"}}'::json);
--}}}
CREATE or REPLACE
FUNCTION actions.get_tables(req json)
RETURNS json
language plv8
as $$
 return plv8.execute("SELECT array_to_json(array_agg(t.*)) as json from test.expanded_resource_tables t")[0]['json']
$$;

--{{{
CREATE or REPLACE
FUNCTION actions.show(req json)
RETURNS json
language plv8
as $$
 return plv8.execute("SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from test.expanded_resource_tables t where resource_name = '" + req.uri_args.resource + "'")[0]['json']
$$;

--SELECT actions.show('{"uri_args": {"resource": "Alert"}}'::json);
--}}}
--{{{
drop function if exists actions.delete_resource(json);
CREATE or REPLACE
FUNCTION actions.delete_resource(req json)
RETURNS json
language plv8
as $$
 var resource_id = req.uri_args.resource_id;
 var sql = "select fhir.delete_resource('" + resource_id + "'::uuid)";
 plv8.elog(NOTICE, sql);
 plv8.execute(sql);
 
 return JSON.stringify({id: resource_id });
$$;

--SELECT actions.delete_resource(('{"uri_args": {"resource_id": "' || (select id from fhir.resource limit 1)::varchar || '"}}')::json);
--}}}
drop function if exists actions.update_resource(json);
CREATE or REPLACE
FUNCTION actions.update_resource(req json)
RETURNS json
language plpgsql
as $$
declare
  resource_id text;
begin
  resource_id := req->'uri_args'->>'resource_id';
  PERFORM fhir.update_resource(resource_id::uuid, req->'request_body');
  return req->'request_body';
end;
$$;
--{{{
--select * from fhir.resource;
--select * from test.expanded_resource_tables;
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.details(req json)
RETURNS json
language plv8
as $$
  var resource_id = req.uri_args.resource_id;
  var resource_type = plv8.execute("SELECT r.resource_type from fhir.resource r where r.id = '" + resource_id + "'")[0]['resource_type'];
  var resource_tables = plv8.execute("SELECT t.* from test.expanded_resource_tables t where resource_name = '" + resource_type + "'");
  var res = [];
  for(var i=0; i<resource_tables.length; i++){
				var rt = resource_tables[i];
				var table_name = rt['table_name'];
				var resource_name = rt['resource_name'];
				var path = rt['path'];
				if (table_name != 'patient_photo') {
				var columns = resource_tables[i]['columns'];
				var where = 'id'
				for (var j=0; j< columns.length; j++) {
							if (columns[j]['column_name'] == 'resource_id') {
												where = 'resource_id';
												}
								}
				var sel = plv8.execute("SELECT * from fhir." + table_name + " where " + where + " = '" + resource_id + "'");
        for(var m=0;m<sel.length;m++){
            var row = sel[m];
            for (var jj=0; jj< columns.length; jj++) {
              var col_name = columns[jj]['column_name'];
              if (row[col_name]) {
                var data_type = columns[jj]['data_type'];
                if (data_type == 'uuid') {
                  row[col_name] = row[col_name].split('-')[0] + '...';
                } else if (data_type == 'date' || data_type == 'timestamp without time zone') {
                
                  row[col_name] = new Date(Date.parse(row[col_name])).toString();
                }
            }
          }
        }
				if (sel.length > 0) {
								var headers = [];
								for(var k in sel[0]) {
												var is = false;
												for(var m=0;m<sel.length;m++){
																if (sel[m][k]) {
																is = true;
																}
																}
												if (is) {headers.push(k);}
												}
								var obj = {'table_name': table_name, 'path': path, headers: headers, data: sel};
								res.push(obj);
				}
				}
		}
   var json = {'resource_name': resource_name, 'resource_id': resource_id, data: res}
	 return JSON.stringify(json);
$$;

--SELECT actions.details(('{"uri_args": {"resource_id": "' || (select id from fhir.resource limit 1)::varchar || '"}}')::json);
--}}}

--{{{
--SELECT t.path from test.expanded_resource_tables t;

--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.query(req json)
RETURNS json
language plv8
as $$
 var sql =  "SELECT array_to_json(array_agg(row_to_json(t.*)))::varchar as json from (" + req.uri_args.q + ") t"
 plv8.elog(NOTICE, sql)
 var resultates = plv8.execute(sql);
 if (resultates[0]['json']) {
   return resultates[0]['json'];
 } else {
  return ['there is no result (n\'existe pas)'];
 }
$$;

--SELECT actions.query('{"uri_args": {"q": "select * from fhir.patient"}}'::json);
--}}}

--{{{
CREATE or REPLACE
FUNCTION actions.resource(req json)
RETURNS json
language plv8
as $$
  var res = [];
  var list = plv8.execute('select id, _type from fhir.resource');
  for(var i=0; i<list.length; i++){
				var id = list[i]['id'];
				var view = list[i]['_type'];
				var obj = plv8.execute("SELECT t.json from fhir.view_" + view + " t where id = '" + id + "'")[0]['json'];
				res.push(obj);
				}
	return JSON.stringify(res);
$$;

SELECT actions.resource('{"uri_args": {"type": "patient"}}'::json);
--}}}

--{{{
DROP FUNCTION actions.create_resource(json);
CREATE OR REPLACE
FUNCTION actions.create_resource(body json)
RETURNS json
language plpgsql AS $$
BEGIN
  RETURN ('{"id": "' || fhir.insert_resource(body->'request_body') || '"}')::json;
END
$$;

--SELECT actions.create_resource('{"request_body": {"resourceType": "Patient"}, "uri_args": {"type": "patient"}}'::json);
--}}}
--{{{
--SELECT ('{"id": "' || fhir.insert_resource('{"resourceType": "Patient"}'::json) || '"}')::json;
delete from fhir.resource;
SELECT ('{"id": "' || fhir.insert_resource('{"resourceType": "Patient"}'::json) || '"}')::json;
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
--}}}
