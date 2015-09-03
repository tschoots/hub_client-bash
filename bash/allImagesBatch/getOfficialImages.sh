#!/bin/bash


status=$(boot2docker status)
if [ "$status" != "running" ]; then
 boot2docker up
fi
eval $(boot2docker shellinit)

# now docker infra is in place


# allowed characters to search, - is not allowed to be in first or last position.
declare -a queryChars=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 _ . -)
#declare -a queryChars=(a b c 7 8 9 _ . -)
# This function replaces the last string by the next as defined in the above array
function nextSearchString() {
  local len=${#queryChars[@]}
  local _input=$1
  local _lastChar=${_input: -1}
  if [ "$_lastChar" == "-" ]; then
      nextLastChar="a"
  else
      for (( i=0; i<len;i++ )); 
      do  
      if [ "${queryChars[i]}" == "$_lastChar" ]; then
         nextLastChar="${queryChars[i+1]}"
         break
      fi  
      done
  fi  
  output=$(echo $_input | sed "s/.$/"$nextLastChar"/")
  echo $output
}


declare -a officialImages
declare -a unofficialImages

# invariant is : the first character in search string should not be -
# because this is not allowed in docker.
# then in the loop it should be checked if the next last character is -
#   if so remove last character and increase the new last character
# If the amount of returned images is 25 concat searchstring with "a"
# if returned images less than 25 get the next char on the last position.:w

searchString="a"
while [ ! "$searchString" == "-" ]
do
   declare -a images=($(docker search $searchString |  grep -v "NAME" | awk '{print  $1}'))
   for image in "${images[@]}"
   do
     tmp=$(echo $image | grep "/")
     nr=${#tmp}
     if [ "$nr" -gt "0"  ]; then
        unofficialImages+=("$image")
     else
        officialImages+=("$image")
     fi
   done
   # now go for the next search string
   echo "SearchString : $searchString"
   nr_img=${#images[@]}
   if [ "${searchString: -1}" == "." ]; then
      # remove last character and replace the new last char
      if [ "${#searchString}" -gt "1" ]; then
        searchString=$(echo $searchString | sed 's/.$//')
      fi
      searchString=$(nextSearchString "$searchString")
   elif [ "$nr_img" -eq  "25" ]; then
      searchString=$(echo "$searchString""a")
   elif [ "$nr_img" -lt  "25" ]; then
      searchString=$( nextSearchString "$searchString")
   fi
   #clean up the arrays so only unique values are there
   officialImages=($(printf "%s\n" "${officialImages[@]}" | sort -u))
   unofficialImages=($(printf "%s\n" "${unofficialImages[@]}" | sort -u))
done

echo  "official images : ${#officialImages[@]}"
echo  "unofficial images : ${#unofficialImages[@]}"

printf "%s\n" "${officialImages[@]}" > officialImages.txt
printf "%s\n" "${unofficialImages[@]}" > unofficialImages.txt
