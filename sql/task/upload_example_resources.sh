# upload fhir resources into example table
HM=`pwd`
DB='myfhir'

echo '' > tmp.sql
for f in ../../data/*json
do
  echo "Processing $f"
  echo "\\set json \`cat $HM/$f\`" >> tmp.sql
  echo "INSERT INTO demo.example_resource (file, json) VALUES (E'$f', :'json'::json);" >> tmp.sql
done
psql -d $DB -c "TRUNCATE TABLE demo.example_resource"
cat tmp.sql | psql -d $DB
psql -d $DB -c "UPDATE demo.example_resource SET file = replace(file, '../../data/', '');"
psql -d $DB -c "select count(*) from demo.example_resource"

