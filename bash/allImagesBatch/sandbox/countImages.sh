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

# take the input name and construct the done file name
_IMAGES_CLEAN=$(echo $1 | sed 's/\(\..*$\)/_clean\1/')
#declare -a images_done
#if [ -f $_IMAGES_DONE ]; then
#   while read img; do
#      images_done+=("$img")
#   done < $_IMAGES_DONE
#   images_done=($(printf "%s\n" "${images_done[@]}" | sort -u))
#fi

declare -a images
while read image; do
  #echo $image
  images+=("$image")
done <  $_IMAGES_FILE

# clean array with original values 
images=($(printf "%s\n" "${images[@]}" | sort -u))

for i in "${images[@]}"; do
  echo $i >> $_IMAGES_CLEAN
done

#echo ${images[0]} >> $_IMAGES_CLEAN
#echo ${images[1]} >> $_IMAGES_CLEAN

echo ${#images[@]}
