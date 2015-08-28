#!/bin/bash

# check the input parametes, it should be  dockerimage , tag
if [ "$#" -ne 2  ]; then
   echo "not enough parameters"
   echo "dockerimage"
   echo "tag"
   exit
fi

set -x

# maybe check amount of ram , boot2docker info
memory=$(boot2docker info | grep "Memory")
echo $memory

# check if the boot2docker-vm is running.
status=$(boot2docker status)
echo "status docker " $status
if [ "$status" == "poweroff" ]; then
   echo "start up boot2docker"
   $(boot2docker up)
elif [ "$status" == "aborted" ];then
   $(boot2docker up)
fi


#initialize the shell so docker commands can be performed.
eval $(boot2docker shellinit)

# take out the / and replace for - in the json file name
a=$(echo "$1_$2" | sed 's/\//-/g')
$(docker run --privileged --rm -ti -v `pwd`:/tmp $1:$2 /tmp/get_packages.sh $1 $2)

if [ ! -e ./$a.json ]; then
  # json file not generated
  exit 1
fi

#now upload the json file
# To do : parameterize the server , port , user , password
#java -jar postJSON.jar https://hub-docker.blackducksoftware.com 443 docker docker ./$a.json
#java -jar postJSON.jar http://tons-mackbook-pro.local 8080 docker docker ./$a.json
java -jar postJSON.jar https://saleshub.blackducksoftware.com 443 tschoots blackduck ./$a.json


#open the browser to view the report
urlFile=./$a.url
#if [ -f ./$a.url ];then
if [ -f $urlFile ];then
  url=$(cat ./$a.url)
  html=./$a.html
  comp="./${a}_comp.html"
  echo $html
  if [ -f /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome ];then
     open -a "Google Chrome" $comp 
     open -a "Google Chrome" $html 
     open -a "Google Chrome" $url 
  elif [ -f /Applications/Firefox.app/Contents/MacOS/firefox ];then
     open -a Firefox $comp
     #open -a Firefox $html
     open -a Firefox $url
  elif [ -f /Applications/Safari.app/Contents/MacOS/Safari ];then
     open -a safari $comp 
     #open -a safari $html 
     open -a safari $url 
  else
     echo "no browser found"
  fi
else
  echo "file : " $a ".url not found"
fi
# open -a safari $url 
# To do : cleanup image and json file
