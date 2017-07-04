#!/bin/bash
usage(){
    echo  'usage: bash create-user-provided-service.sh [-f  <file path to JSON file>] '
    echo 'Make sure you are in the right space and trying logging in using cf login'

}

FILE="creds.json"
HASFILE=
while getopts "f:" OPTIONS
do
    case $OPTIONS in
        f) 
            FILE=$OPTARG
            HASFILE=1
            ;;
    esac
done

if [ -z $HASFILE ]
then
    echo "REMOVE CRED.JSON IF EXIST"
    if [ -f $FILE ]
    then
        rm $FILE
    fi
    echo "CREATE TEMP FILE WITH configuration from env"
    echo "{" > creds.json
    echo "\"PHIX_ENDPOINT_SUBMISSION\":\"$PHIX_ENDPOINT_SUBMISSION\"," >> creds.json
    echo "\"CLAMAV_ENDPOINT\":\"$CLAMAV_ENDPOINT\"," >> creds.json
    echo "\"CRYPTO_PASSWORD\":\"$CRYPTO_PASSWORD\"," >> creds.json
    echo "\"JWT_TOKEN_SECRET_KEY\":\"$JWT_TOKEN_SECRET_KEY\"," >> creds.json
    echo "\"PHIX_ENDPOINT_DICTIONARY\":\"$PHIX_ENDPOINT_DICTIONARY\"," >> creds.json
    echo "\"PHIX_ENDPOINT_RETRIEVAL\":\"$PHIX_ENDPOINT_RETRIEVAL\"," >> creds.json
    echo "\"PHIX_ENDPOINT_RETRIEVAL_TOKEN\":\"$PHIX_ENDPOINT_RETRIEVAL_TOKEN\"," >> creds.json
    echo "\"PHIX_ENDPOINT_SUBMISSION_TOKEN\":\"$PHIX_ENDPOINT_SUBMISSION_TOKEN\"," >> creds.json
        echo "\"PHIX_ENDPOINT_SUBMISSION\":\"$PHIX_ENDPOINT_SUBMISSION\"," >> creds.json
    echo "\"POSTGRES_READONLY_ROLE\":\"$POSTGRES_READONLY_ROLE\"," >> creds.json
    echo "\"TZ\":\"$TZ\"" >> creds.json
    echo "}" >> creds.json
else
    echo "USE $FILE"
fi



echo "CREATE USER PROVIDED"
UPS=$(cf services | grep env_setup)
if [ -z "$UPS" ] 
then
    cf cups env_setup -p $FILE
else
   cf uups env_setup -p $FILE
fi

echo "DELETE TEMP FILE"
if [ -z HASFILE ]
then
    rm $FILE
fi
