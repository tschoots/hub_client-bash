#!/bin/bash

    



################  MAIN  #############

# check the input parametes, it should be project name , release
if [ "$#" -ne 2  ]; then
   echo "not enough parameters"
   echo "project_name"
   echo "release"
   exit
fi

# take out the / and replace for - in the json file name
a=$(echo "$1_$2" | sed 's/\//-/g')
logfile="/tmp/$a.log"

date >> $logfile

#determine what os we are on and if we can use dpkg or rpm
os=$(cat /etc/os-release | grep "^ID=" | sed s/"^ID="/""/)
version=$(cat /etc/os-release | grep "^VERSION_ID=" | sed s/"^VERSION_ID="/""/)
dpkg=$(command -v dpkg)
rpm=$(command -v rpm)
echo "rpm $rpm, dpkg : $dpkg"
package_manager="no rpm or dpkg package manager"
if [  -z $dpkg  ];then
   echo "rpm"
   package_manager="rpm"
elif [ -z $rpm   ];then
   echo "dpkg"
   package_manager="dpkg"
else
   echo "no rpm or dpkg"
fi

echo "operating system : $os, version : $version, package manager: $package_manager"
echo "operating system : $os, version : $version, package manager: $package_manager" >> $logfile


jsonString="{\"bds_hub_project\":\"$1\",\"bds_hub_project_release\":\"$2\",\"ossComponentsToMatch\":["
if [ $package_manager = "dpkg" ]; then
   #jsonString+=$(dpkg -l | grep "ii" |  sed 's/ii/{"name":"/' |    awk  '{   print $1 $2 "\",\"version\":\"" $3 "\"}," ;}')
   jsonString+=$(dpkg -l | grep "ii" |  sed 's/\(^ii\s*\S*\):\S*\(\s.*\)/\1\2/' | sed 's/ii/{"name":"/' |    awk  '{   print $1 $2 "\",\"version\":\"" $3 "\"}," ;}')
elif [ $package_manager = "rpm" ]; then
   echo "redhat or centos"
   echo "fedora"
   jsonString+=$(rpm -qa --queryformat "\{\"name\":\"%{NAME}\",\"version\":\"%{VERSION}\"\},")
else
   echo "operating system not recognized"
   echo "operating system not recognized" >> $logfile
   echo "nothing generated"
   echo "nothing generated" >> $logfile
   exit
fi

#remove trailing , and add the ending brackets
jsonString="${jsonString%?}"
jsonString+="]}"

echo $jsonString > /tmp/$a.json
