#!/bin/bash
###############################################################################
# Curl commands to create API Protection Model
#
# jvigueras@fortinet.com
###############################################################################

#------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------
NUM_CALLS=300

#------------------------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------------------------
# Function to check if the input matches the pattern
check_input_pattern() {
    local URL="$1"
    local pattern1="fortixpert[1-9]\-api\.hol\.fortidemoscloud\.com"
    local pattern2="fortixpert[1-9][0-9]\-api\.hol\.fortidemoscloud\.com"
    if [[ ! $URL =~ $pattern1 ]]; then
      if  [[ ! $URL =~ $pattern2 ]]; then
        echo "la URL no cumple con el formato correcto."
        exit 1
      fi
    fi
}

#------------------------------------------------------------------------------
# CODE
#------------------------------------------------------------------------------
# Read input from command line arguments if provided, otherwise prompt the user
if [ -n "$1" ]; then
    URL="$1"
else
    read -p "Introduce la URL: " URL
fi

# Call the function to check the input pattern
check_input_pattern "$URL"

NAMES=(FortiPuma FortiFish FortiSpider FortiTiger FortiLion FortiShark FortiSnake FortiMonkey FortiFox FortiRam FortiEagle FortiBee FortiCat FortiDog FortiAnt FortiWasp FortiPanter FortiGator FortiOwl FortiWildcats)
PETS=(Puma Fish Spider Tiger Lion Shark Snake Monkey Fox Ram Eagle Bee Cat Dog Ant Wasp Panter Gator Owl Wildcats)
STATUS=(available pending sold available pending sold available pending sold available pending sold available pending sold available pending sold available pending)

ID=400

echo "-------------------------------------------------------------------------------------------------------------------"
echo "Sending API POST requests to ${URL}/ to populate pets entries with FortiPets"
echo "-------------------------------------------------------------------------------------------------------------------"

for ((i=0; i<NUM_CALLS; i++))
do
  IPADDRESS=$(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g')
  echo -n "POST : ${URL} - HTTP status = "
  curl -k -H "X-Forwarded-For: ${IPADDRESS}" -A ML-Requester -s -o /dev/null -w "%{http_code}" -X 'POST' \
    "${URL}/api/pet" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
  -d "{\
    \"id\": $ID,\
    \"category\": {\
      \"id\": $ID,\
      \"name\": \"${PETS[$i]}\"\
    },\
    \"name\": \"${NAMES[$i]}\",\
    \"photoUrls\": [\
      \"Willupdatelater\"\
    ],\
    \"tags\": [\
      {\
        \"id\": $ID,\
        \"name\": \"${NAMES[$i]}\"\
      }\
    ],\
    \"status\": \"${STATUS[$i]}\"\
    }"
    echo ""

  ID=$((ID+1))
done

echo "-------------------------------------------------------------------------------------------"
echo "FortiWeb ML-API trained with POST method on ${URL}/"
echo "-------------------------------------------------------------------------------------------"
