#!/bin/sh

echo 'Make sure you are in the right space and trying logging in using cf login'
echo  'usage: bash create-user-provided-service.sh <file path to JSON file> <app name to bind the service to>'

json_file=$1
app=$2

if [ "$json_file" -a "$app" ]
then
    cf uups env_setup -p $json_file
    cf bs $app env_setup
else
    echo 'Unable to create/bind the service: invalid path or file does not exist or check your app name'
fi