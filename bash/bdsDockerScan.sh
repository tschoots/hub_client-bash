#!/bin/bash

# check the input parametes, it should be  dockerimage , tag
if [ "$#" -ne 2  ]; then
   echo "not enough parameters"
   echo "dockerimage"
   echo "tag"
   exit
fi

# maybe check amount of ram , boot2docker info
memory=$(boot2docker info | grep "Memory")
echo $memory

# check if the boot2docker-vm is running.
status=$(boot2docker status)
if [ "$status" == "poweroff" ]; then
   echo "start up boot2docker"
   $(boot2docker up)
fi


#initialize the shell so docker commands can be performed.
eval $(boot2docker shellinit)

# take out the / and replace for - in the json file name
a=$(echo "$1_$2" | sed 's/\//-/g')
output=$(docker run --privileged --rm -ti -v `pwd`:/tmp $1:$2 /tmp/get_packages.sh $1 $2  > /tmp/$a.json)
echo $output
