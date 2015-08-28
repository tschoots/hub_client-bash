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

package_manager="no rpm or dpkg package manager"
if [ "$os" = "slackware" ];then
   package_manager="pkgtool"
elif [  "$os" = "alpine"  ];then
   package_manager="apk"
elif [  -z $dpkg  ];then
   package_manager="rpm"
elif [ -z $rpm   ];then
   package_manager="dpkg"
else
   echo "NO PACKAGE MANAGER FOUND!"   
fi

echo "operating system : $os, version : $version, package manager: $package_manager"
echo "operating system : $os, version : $version, package manager: $package_manager" >> $logfile


nr_components="0"
jsonString="{\"bds_hub_project\":\"$1\",\"bds_hub_project_release\":\"$2\",\"ossComponentsToMatch\":["
if [ $package_manager = "dpkg" ]; then
   #jsonString+=$(dpkg -l | grep "ii" |  sed 's/ii/{"name":"/' |    awk  '{   print $1 $2 "\",\"version\":\"" $3 "\"}," ;}')
   jsonString+=$(dpkg -l | grep "ii" |  sed 's/\(^ii\s*\S*\):\S*\(\s.*\)/\1\2/' | sed 's/ii/{"name":"/' |    awk  '{   print $1 $2 "\",\"version\":\"" $3 "\"}," ;}')
   nr_components=$(dpkg -l | grep "ii" |  wc -l)
elif [ $package_manager = "rpm" ]; then
   echo "redhat or centos"
   echo "fedora"
   jsonString+=$(rpm -qa --queryformat "\{\"name\":\"%{NAME}\",\"version\":\"%{VERSION}\"\},")
   nr_components=$(rpm -qa | wc -l)
elif [ $package_manager = "pkgtool" ]; then
   jsonString+=$(ls /var/log/packages/ | sed 's/-/     /g' | awk '{print "{\"name\":\"" $1 "\",\"version\":\"" $2 "\"},"}')
   nr_components=$(ls /var/log/packages/ | wc -l)
else
   echo "operating system not recognized"
   echo "operating system not recognized" >> $logfile
   echo "nothing generated"
   echo "nothing generated" >> $logfile
   exit
fi

echo "number of components" $nr_components
echo "number of components" $nr_components >> $logfile

#remove trailing , and add the ending brackets
jsonString="${jsonString%?}"
jsonString+="]}"

echo $jsonString > /tmp/$a.json
