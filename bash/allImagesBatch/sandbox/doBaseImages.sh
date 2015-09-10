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

_LOG_FILE=$(echo $1 | sed 's/\(\..*$\)/_error_images\1/')

# take the input name and construct the done file name
_IMAGES_DONE=$(echo $1 | sed 's/\(\..*$\)/_done\1/')
echo $_MAGES_DONE
declare -a images_done
if [ -f "$_IMAGES_DONE" ]; then
   while read img; do
      images_done+=("$img")
   done < $_IMAGES_DONE
   images_done=($(printf "%s\n" "${images_done[@]}" | sort -u))
fi

declare -a images
while read image; do
  #echo $image
  images+=("$image")
done <  $_IMAGES_FILE

# clean array with original values 
images=($(printf "%s\n" "${images[@]}" | sort -u))


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

for i in "${images[@]}"; do
  # take out the / and replace for - in the json file name
  a=$(echo "$i""_latest" | sed 's/\//-/g')
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
done


