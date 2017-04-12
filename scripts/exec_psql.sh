#!/bin/bash

echo "Running PSQL scripts"
# # retrive credential from VCAP. 
# # save pass into a file ".pgpass"

export PGPASSWORD=PUONXOHGXDBQCGFC 
psql -U admin -d compose -p 22334 -h sl-us-dal-9-portal.6.dblayer.com --no-password -f /tmp/scripts/1_Add_Roles.sql

printenv VCAP_SERVICES_COMPOSE_FOR_POSTGRESQL_0_ENTITY_SERVICE_INSTANCE_URL
echo "PSQL scripts ran"
