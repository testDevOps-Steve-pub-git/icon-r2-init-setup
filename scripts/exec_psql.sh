#!/bin/bash

echo "Running PSQL scripts"
# # retrive credential from VCAP. 
# # save pass into a file ".pgpass"

export PGPASSWORD=PUONXOHGXDBQCGFC 
psql -U admin -d compose -p 22334 -h sl-us-dal-9-portal.6.dblayer.com --no-password -f /tmp/scripts/1_Add_Roles.sql

env 
echo "PSQL scripts ran"
