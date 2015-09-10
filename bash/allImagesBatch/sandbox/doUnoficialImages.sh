#!/bin/bash

if [ $# -ne 1 ]; then
   #not right input parameter
   echo "not right input parameters , useage : $0 <file with image names>"
   exit
fi

_IMAGES_FILE=$(echo $1)
#check if input file exist
if [ ! -f $_IMAGES_FILE ]; then
   # input file doesn't exist quit
   echo "$1 doesn't exist"
   exit
fi


_IMAGES_DONE=$(echo $1 | sed 's/\(\..*$\)/_done\1/')
_IMAGES_TODO=$(echo $1 | sed 's/\(\..*$\)/_todo\1/')
_IMAGES_TMP=$(echo $1 | sed 's/\(\..*$\)/_tmp\1/')
_LOG_FILE=$(echo $1 | sed 's/\(\..*$\)/_error_images\1/')





# maybe check amount of ram , boot2docker info
memory=$(docker-machine inspect --format='{{.Driver.Memory}}' default)
echo $memory

# check if the boot2docker-vm is running.
status=$(docker-machine ls default | grep -v "NAME" | awk '{print $3}')
echo "status docker " $status
if [ "$status" != "Running" ]; then
   $(docker-machine start default)
fi

set -x

#initialize the shell so docker commands can be performed.
eval "$(docker-machine env default)"

#for i in "${images[@]}"; do
$(tail -n +1 $_IMAGES_FILE > $_IMAGES_TODO)
while read i; do
  # take out the / and replace for - in the json file name
  a=$(echo "$i""_latest" | sed 's/\(.*\)\//unofficial_\1-/')
  $(docker run --privileged --rm -ti  -v `pwd`:/tmp $i:"latest" /tmp/get_packages.sh $i "latest")

  if [ ! -e ./$a.json ]; then
     # json file not generated
     #exit 1
     echo $i >> $_LOG_FILE 
  fi

  #now upload the json file
  # To do : parameterize the server , port , user , password
  java -jar postJSON.jar https://hub-docker.blackducksoftware.com 443 sysadmin blackduck ./$a.json
  #java -jar postJSON.jar http://tons-mackbook-pro.local:8080 8080 docker docker ./$a.json
  #java -jar postJSON.jar https://saleshub.blackducksoftware.com 443 tschoots blackduck ./$a.json
  echo $i >> $_IMAGES_DONE
  # remove the pulled images
  docker rmi $i
  # update todo list
  $(tail -n +2  $_IMAGES_TODO > $_IMAGES_TMP)
  $(tail -n +1  $_IMAGES_TMP > $_IMAGES_TODO)
done < $_IMAGES_FILE


