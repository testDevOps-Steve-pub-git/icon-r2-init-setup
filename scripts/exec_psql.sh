#!/bin/bash
echo "Running PSQL scripts"

echo "Retrieve credential from VCAP"
URL=$(printenv VCAP_SERVICES_COMPOSE_FOR_POSTGRESQL_0_CREDENTIALS_URI)

USER=$(echo $URL | cut -d ':' -f 2 | cut -d '/' -f 3)
export PGPASSWORD=$(echo $URL | cut -d ':' -f 3 | cut -d '@' -f 1)
HOST=$(echo $URL | cut -d ':' -f 3 | cut -d '@' -f 2)
PORT=$(echo $URL | cut -d ':' -f 4 | cut -d '/' -f 1)
DBNAME=$(echo $URL | cut -d ':' -f 4 | cut -d '/' -f 2)


echo "Preparing for SQL scripting"
runPSQL() {
  psql -U $USER -d $DBNAME -p $PORT -h $HOST --no-password -f /tmp/scripts/$1
}

echo "Running Drop_DB.sql"
runPSQL Drop_DB.sql

echo "Running 1_Add_Roles.sql"
runPSQL 1_Add_Roles.sql

echo "Running 2_Create_Lookup_DB.sql"
runPSQL 2_Create_Lookup_DB.sql

echo "Running 3_Create_Submit_DB.sql"
runPSQL 3_Create_Submit_DB.sql

echo "Unzip 4_Geocode_Data.sql.zip and running 4_Geocode_Data.sql"
tar xvf 4_Geocode_Data.sql.zip
runPSQL 4_Geocode_Data.sql

echo "Running 5_Lookup_Data.sql"
runPSQL 5_Lookup_Data.sql


echo "PSQL scripting completed"