###############################################################################
# PowerShell script commands to create API Protection Model
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
function Check-InputPattern {
    param (
        [string]$URL
    )
    $pattern1 = "fortixpert[1-9]-api\.hol\.fortidemoscloud\.com"
    $pattern2 = "fortixpert[1-9][0-9]-api\.hol\.fortidemoscloud\.com"
    if ($URL -notmatch $pattern1 -and $URL -notmatch $pattern2) {
        Write-Host "la URL no cumple con el formato correcto."
        exit 1
    }
}

#------------------------------------------------------------------------------
# CODE
#------------------------------------------------------------------------------
# Read input from command line arguments if provided, otherwise prompt the user
if ($args.Count -gt 0) {
    $URL = $args[0]
} else {
    $URL = Read-Host "Introduce la URL"
}

# Call the function to check the input pattern
Check-InputPattern $URL

$NAMES=("FortiPuma", "FortiFish", "FortiSpider", "FortiTiger", "FortiLion", "FortiShark", "FortiSnake", "FortiMonkey", "FortiFox", "FortiRam", "FortiEagle", "FortiBee", "FortiCat", "FortiDog", "FortiAnt", "FortiWasp", "FortiPanter", "FortiGator", "FortiOwl", "FortiWildcats")
$PETS=("Puma", "Fish", "Spider", "Tiger", "Lion", "Shark", "Snake", "Monkey", "Fox", "Ram", "Eagle", "Bee", "Cat", "Dog", "Ant", "Wasp", "Panter", "Gator", "Owl", "Wildcats")
$STATUS=("available", "pending", "sold", "available", "pending", "sold", "available", "pending", "sold", "available", "pending", "sold", "available", "pending", "sold", "available", "pending", "sold", "available", "pending")

$ID=400

Write-Host "-------------------------------------------------------------------------------------------------------------------"
Write-Host "Sending API POST requests to ${URL}/ to populate pets entries with FortiPets"
Write-Host "-------------------------------------------------------------------------------------------------------------------"

for ($i=0; $i -lt $NUM_CALLS; $i++) {
    $IPADDRESS = Get-Random -Minimum 0 -Maximum 255
    $IPADDRESS = "$IPADDRESS.$IPADDRESS.$IPADDRESS.$IPADDRESS"
    Write-Host -NoNewline "POST : ${URL} - HTTP status = "
    Invoke-RestMethod -Uri "${URL}/api/pet" -Method Post -Headers @{
        "X-Forwarded-For" = $IPADDRESS
        "User-Agent" = "ML-Requester"
        "accept" = "application/json"
        "Content-Type" = "application/json"
    } -Body @"
    {
        "id": $ID,
        "category": {
            "id": $ID,
            "name": "${PETS[$i]}"
        },
        "name": "${NAMES[$i]}",
        "photoUrls": [
            "Willupdatelater"
        ],
        "tags": [
            {
                "id": $ID,
                "name": "${NAMES[$i]}"
            }
        ],
        "status": "${STATUS[$i]}"
    }
    "@ -UseBasicParsing | Out-Null
    $StatusCode = $LastStatusCode
    Write-Host $StatusCode

    $ID++
}

Write-Host "-------------------------------------------------------------------------------------------"
Write-Host "FortiWeb ML-API trained with POST method on ${URL}/"
Write-Host "-------------------------------------------------------------------------------------------"
