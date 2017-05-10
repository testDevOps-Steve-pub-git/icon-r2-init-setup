#!/bin/bash


if [ $# -ne 2 ]
  then
    echo "usage: exec_psql service-user-defined-name credential-name"
  else
    echo "Getting credential of Postgresql"
    URL=$(cf service-key $1 $2 | grep uri\":)

    if [ -z $URL ]
      then 
        exit 1
    fi

    USER=$(echo $URL | cut -d ':' -f 3 | cut -d '/' -f 3)
    export PGPASSWORD=$(echo $URL | cut -d ':' -f 4 | cut -d '@' -f 1)
    HOST=$(echo $URL | cut -d ':' -f 4 | cut -d '@' -f 2)
    PORT=$(echo $URL | cut -d ':' -f 5 | cut -d '/' -f 1)
    DBNAME=$(echo $URL | cut -d ':' -f 5 | cut -d '/' -f 2 | tr -d "\",")

    echo "Preparing for SQL scripting"
    runPSQL() {
      psql -U $USER -d $DBNAME -p $PORT -h $HOST --no-password -f $1
    }

    echo "Running Drop_DB.sql"
    runPSQL Drop_DB.sql

    echo "Running 1_Add_Roles.sql"
    runPSQL 1_Add_Roles.sql

    echo "Running 2_Create_Lookup_DB.sql"
    runPSQL 2_Create_Lookup_DB.sql

    echo "Running 3_Create_Submit_DB.sql"
    runPSQL 3_Create_Submit_DB.sql

    echo "Unzip 4_Geocode_Data.sql.zip"
    unzip  4_Geocode_Data.sql.zip
    echo "Run 4_Geocode_Data.sql"
    runPSQL 4_Geocode_Data.sql

    echo "Running 5_Lookup_Data.sql"
    runPSQL 5_Lookup_Data.sql

    echo "PSQL scripting completed"
fi


