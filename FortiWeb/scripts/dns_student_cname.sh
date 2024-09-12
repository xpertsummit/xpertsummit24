#!/bin/bash
# Script to crate new CNAME record in lab DNS zone

# Variables
HOSTED_ZONE_ID="Z0507506RNJD04O8Q048"
DNS_NAME="xpertsummit-es.com"
EXTERNAL_TOKEN_ID=""
RECORD_VALUE=""

# Input LAB token
read -p "Introduce el token del laboratorio: " EXTERNAL_TOKEN_ID

# Trim leading and trailing spaces
EXTERNAL_TOKEN_ID=$(echo "$EXTERNAL_TOKEN_ID" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Check if the input is not blank and is 30 characters long
if [ -z "$EXTERNAL_TOKEN_ID" ]; then
  echo "Debes introducir el token del laboratorio."
  exit 1
elif [ ${#EXTERNAL_TOKEN_ID} -ne 30 ]; then
  echo "El token debe tener exactamente 30 caracteres."
  exit 1
fi

# Input FortiWEB Cloud student URL
read -p "Introduce el FQDN de FortiWEB Cloud: " RECORD_VALUE

# Trim leading and trailing spaces
RECORD_VALUE=$(echo "$RECORD_VALUE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Check if the input is not blank and is 30 characters long
if [ -z "$RECORD_VALUE" ]; then
  echo "Debes introducir el FQDN de tu aplicación en FortiWEB Cloud."
  exit 1
fi

# Install jq
sudo yum install -y jq > /dev/null 

# Get user ARN
caller_identity=$(aws sts get-caller-identity)
# Extract lab Owner from AWS caller identity
account_id=$(echo "$caller_identity" | jq -r '.Account')
lab_owner=$(echo "$caller_identity" | jq -r '.Arn' | awk -F '[:/]' '{print $NF}')
iam_role_name="role-$lab_owner"

# Assume the IAM role to create new DNS record
assume_role_output=$(aws sts assume-role --role-arn "arn:aws:iam::$account_id:role/$iam_role_name" --role-session-name "StudentRole" --external-id "$EXTERNAL_TOKEN_ID")

# Set AWS environment variables with temporary credentials
export AWS_ACCESS_KEY_ID="$(echo "$assume_role_output" | jq -r '.Credentials.AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(echo "$assume_role_output" | jq -r '.Credentials.SecretAccessKey')"
export AWS_SESSION_TOKEN="$(echo "$assume_role_output" | jq -r '.Credentials.SessionToken')"

# DNS record CNAME variables
RECORD_NAME="$lab_owner.$DNS_NAME" # Compose record name
RECORD_TYPE="CNAME"  # Change the record type to CNAME
RECORD_TTL=300

echo "Creando nueva entrada CNAME: $RECORD_VALUE \n"
# Create the new Route 53 record
aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "'"$RECORD_NAME"'",
        "Type": "'"$RECORD_TYPE"'",
        "TTL": '"$RECORD_TTL"',
        "ResourceRecords": [
          {
            "Value": "'"$RECORD_VALUE"'"
          }
        ]
      }
    }
  ]
}'

# Unset AWS environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo "Tu aplicación estará disponible en breve en http://$RECORD_NAME"