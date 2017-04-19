#!/bin/sh

if [ $# -eq 0 ]
  then
    echo  'usage: bash create-user-provided-service.sh <file path to JSON file> <app name to bind the service to>'
    echo 'Make sure you are in the right space and trying logging in using cf login'
  else
    json_file=$1

    if [ "$json_file" ]
    then
        UPS=$(cf services | grep env_setup)
        if [ -z "$UPS" ] 
        then
            cf cups env_setup -p $json_file
        else
            cf uups env_setup -p $json_file
        fi
    else
        echo 'Unable to create/bind the service: invalid path or file does not exist or check your app name'
    fi
fi