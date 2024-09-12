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

echo "------------------------------------------------------------------------"
echo "Sending API GET requests to ${URL}/"
echo "------------------------------------------------------------------------"

for ((i=1; i<NUM_CALLS; i++))
do
  echo -n "GET : ${URL} - HTTP status = "
  IPADDRESS=$(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g')
  curl  -k -H "X-Forwarded-For: ${IPADDRESS}" -A ML-Requester -s -o /dev/null -X 'GET' -w "%{http_code}" \
  "${URL}/api/pet/findByStatus?status=available" \
  -H 'accept: application/json' \
  -H 'content-type: application/json'
  echo ""

  echo -n "GET : ${URL} - HTTP status = "
  IPADDRESS=$(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g')
  curl -k -H "X-Forwarded-For: ${IPADDRESS}" -A ML-Requester -s -o /dev/null -X 'GET' -w "%{http_code}" \
  "${URL}/api/pet/findByStatus?status=pending" \
  -H 'accept: application/json' \
  -H 'content-type: application/json'
  echo ""

  echo -n "GET : ${URL} - HTTP status = "
  IPADDRESS=$(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g')
  curl -k -H "X-Forwarded-For: ${IPADDRESS}" -A ML-Requester -s -o /dev/null -X 'GET' -w "%{http_code}" \
  "${URL}/api/pet/findByStatus?status=sold" \
  -H 'accept: application/json' \
  -H 'content-type: application/json'
  echo ""
done

echo "-------------------------------------------------------------------------------------------"
echo "FortiWeb ML-API trained with GET method on ${URL}/"
echo "-------------------------------------------------------------------------------------------"
