#!/bin/bash

while [ 1 ]
do 
 echo "something"
  sleep 5
done
# retrive credential from VCAP. 
# save pass into a file ".pgpass"
# psql -U admin -d compose -p $PORT -h $HOST  -f /tmp/scripts/1_Add_Roles.sql