#!/bin/bash

    


################  MAIN  #############

# check the input parametes, it should be project name , release
if [ "$#" -ne 2  ]; then
   echo "not enough parameters"
   echo "project_name"
   echo "release"
   exit
fi

declare -A PCKMAP
jsonString=""
if [ -f /etc/debian_version ]; then
   jsonString+="{\"bds_hub_project\":\"$1\",\"bds_hub_project_release\":\"$2\",\"ossComponentsToMatch\":["
   jsonString+=$(dpkg -l | grep "ii" |  sed 's/ii/{"name":"/' |    awk  '{   print $1 $2 "\",\"version\":\"" $3 "\"}," ;}')
   jsonString="${jsonString%?}"
   jsonString+="]}"
fi

echo $jsonString > /tmp/$1_$2.json
