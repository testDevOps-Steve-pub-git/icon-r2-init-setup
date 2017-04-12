#!/bin/sh

echo 'Make sure you are in the right space and trying logging in using cf login'
echo  'usage: bash create-services.sh <app name to bind the service to>'

app=$1

if [ "$app" ]
then
    cf update-service compose-for-elasticsearch Standard icon-elasticsearch
    cf update-service compose-for-postgresql Standard icon-postgresql
    cf update-service compose-for-rabbitmq Standard icon-rabbitmq

    # cf bs $app icon-elasticsearch
    # cf bs $app icon-postgresql
    # cf bs $app icon-rabbitmq
else
    echo 'Unable to create/bind the service: check your app name'
fi

