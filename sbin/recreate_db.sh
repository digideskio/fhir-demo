function recreate_db {
  echo "Recreate database... $PGDATABASE"
  cat <<EOF | psql -d postgres
SELECT pg_terminate_backend(pg_stat_activity.pid)
  FROM pg_stat_activity WHERE pg_stat_activity.datname = '$PGDATABASE' AND pid <> pg_backend_pid();
  DROP DATABASE IF EXISTS $PGDATABASE;
  CREATE DATABASE $PGDATABASE;
EOF
  curl $FHIRBASE_URL | sed "s/\\\connect fhirbase/\\\connect $PGDATABASE/g" | psql -p $PGPORT -d $PGDATABASE
  reload_application_scripts
}

function reload_application_scripts {
  cat sql/app/dispatch.sql | psql  -p $PGPORT -d $PGDATABASE
  cat sql/tables/example_resources.sql | psql  -p $PGPORT -d $PGDATABASE
  cat sql/tables/resource_tables.sql | psql  -p $PGPORT -d $PGDATABASE
  cat sql/tables/queries.sql | psql  -p $PGPORT -d $PGDATABASE
  cat sql/app/actions.sql | psql  -p $PGPORT -d $PGDATABASE

  # upload fhir resources into example table

  echo '' > /tmp/tmp.sql
  for f in $FHIR_ROOT/data/*json
  do
    #echo "Processing $f"
    echo "\\set json \`cat $f\`" >> /tmp/tmp.sql
    echo "INSERT INTO demo.example_resource (file, json) VALUES (E'$f', :'json'::json);" >> /tmp/tmp.sql
  done
  psql  -p $PGPORT -d $PGDATABASE -c "TRUNCATE TABLE demo.example_resource"
  cat /tmp/tmp.sql | psql  -p $PGPORT -d $PGDATABASE
  psql  -p $PGPORT -d $PGDATABASE -c "UPDATE demo.example_resource SET file = regexp_replace(file, E'.*/', '');"
  psql  -p $PGPORT -d $PGDATABASE -c "select count(*) from demo.example_resource"
}
