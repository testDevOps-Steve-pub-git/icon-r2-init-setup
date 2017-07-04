#!/bin/bash
TIMEOUT=43200
NOW=0
INTERVAL=10
PSQL_CONTAINER_NAME="${CONTAINER_NAME}_${BUILD_NUMBER}"
while [  $NOW -le $TIMEOUT ]
do
    CONTAINER_STATUS=$(cf ic inspect -f '{{.State.Status}}' ${PSQL_CONTAINER_NAME})
    if [ "$CONTAINER_STATUS" == "Shutdown" -o "$CONTAINER_STATUS" == "Running" -o "$CONTAINER_STATUS" == "Building" ]
    then
         if [ $CONTAINER_STATUS == "Shutdown" ]
         then
             echo "Deleting ${PSQL_CONTAINER_NAME}"
             cf ic rm ${PSQL_CONTAINER_NAME}
             exit 0
         fi
    else
        echo "Cant find container, exit"
        exit 1
    fi
    NOW=$(($NOW + $INTERVAL))
    sleep INTERVAL
done
exit 1
