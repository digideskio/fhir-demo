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
('get', '/data/about', 'about'),
('get', '/data/views', 'views')
;
--}}}
