#!/bin/bash

declare -a queryChars=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 _ . -)
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


for x in "${queryChars[@]}"
do
  echo -e "$x \c"
done


len=${#queryChars[@]}
echo ""
echo -e "( \c"
for (( i=0; i<${len}-1; i++)); 
do
  echo  "[\"${queryChars[i]}\"]=\"${queryChars[i+1]}\" "
done

declare -A animals=( ["moo"]="cow" 
                     ["woof"]="dog")

echo "${animals["moo"]}"

test="abcde"
next=$(nextSearchString "axa")
echo "next char $next"
#test=$(echo $test | sed 's/.$/"${nextChar["${test: -1}"]}"/')
#test=$(echo $test | sed 's/.$/"${nextChar["${test: -1}"]}"/')
echo "$test"
echo "${test: -1}"
test=$(echo $test | sed 's/.$//')
echo $test
# only works for bash 4 echo "${test:: -1}"
if [ "${test: -1}" == "e" ]; then
  echo "say yes"
fi
prr=$(echo   "$test""x")
echo $prr
