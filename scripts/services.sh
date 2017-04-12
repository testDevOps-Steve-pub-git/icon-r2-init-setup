#!/bin/sh

APP='icon-server-devops'
# USER_PROVIDED_OUTPUT=`cf env $APP | awk '/User-Provided/{a=1;print"{";next}/^$/{a=0} END{print "\n}"} a{if(c)printf(","); sub(/:$/,"",$1); printf("%s", "\n\""$1"\" : \""$NF"\""); c=1}'`
# echo $USER_PROVIDED_OUTPUT > userprovided.json

VCAP_SERVICES_OUTPUT=`cf env $APP | awk '/^ "VCAP_SERVICES": {$/ { flag=1;next } /^ }$/ { flag=0 } flag {print}'`
if [ "$VCAP_SERVICES_OUTPUT" ]
then
  echo "{" > services.json
  echo "$VCAP_SERVICES_OUTPUT" >> services.json
  echo "}" >> services.json
else
  echo "Application $APP not found"
  exit 1;
fi
