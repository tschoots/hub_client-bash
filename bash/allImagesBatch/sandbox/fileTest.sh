#!/bin/bash

_SEARCH_STRING_FILE="search_string.txt"

# see if there is a search file if so take the last string.
if [ -e $_SEARCH_STRING_FILE ]; then
  # get the last search string in the file
  searchstring=$(sed -n '$p' $_SEARCH_STRING_FILE)
else
  # no file so start from scratch
  searchstring="a"
fi

echo $searchstring

echo "prr" >> $_SEARCH_STRING_FILE
