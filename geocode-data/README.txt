Unpack the canada.add.zip archive:
$ tar xvf canada.add.zip

Prepare SQL from Canada Post address file:
$ awk -f gen_geo_etl.awk canada.add > load_canada.sql
$ psql -U postgres -f load_canada.sql
