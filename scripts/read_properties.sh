#!/bin/bash
if [ $# -eq 0 ]
  then
    echo 'usage: readProp.sh <location of properties file> <name of property to read>'
  else
    prop_value=""
    getProperty() {
      prop_value=`cat $1 | grep $2 | cut -d'=' -f2`
    }

    getProperty $1 $2
    echo ${prop_value}
fi