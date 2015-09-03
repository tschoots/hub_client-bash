#!/bin/bash


image="prr/tttt"
test=$(echo $image | grep "/")
nr=${#test}

echo $nr
if [ $nr -eq "0"  ]; then
       echo "no" 
     else
       echo "yes" 
     fi  
