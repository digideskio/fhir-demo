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
('GET', '/data/query', 'query'),
('GET', '/data/resource', 'resource'),
('GET', '/data/demo', 'demo'),
('GET', '/data/demo/by_attr', 'demo_by_attr'),
('POST', '/data/resource/create', 'create_resource')
;
--}}}
