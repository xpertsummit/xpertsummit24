###############################################################################
# PowerShell script to create API Protection Model
#
# jvigueras@fortinet.com
###############################################################################

#------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------
$NUM_CALLS=300

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

Write-Host "------------------------------------------------------------------------"
Write-Host "Sending API GET requests to ${URL}/"
Write-Host "------------------------------------------------------------------------"

for ($i=1; $i -lt $NUM_CALLS; $i++) {
    Write-Host -NoNewline "GET : ${URL} - HTTP status = "
    $IPADDRESS = Get-Random -Minimum 0 -Maximum 255
    $IPADDRESS = "$IPADDRESS.$IPADDRESS.$IPADDRESS.$IPADDRESS"
    Invoke-RestMethod -Uri "${URL}/api/pet/findByStatus?status=available" -Method Get -Headers @{
        "X-Forwarded-For" = $IPADDRESS
        "User-Agent" = "ML-Requester"
        "accept" = "application/json"
        "content-type" = "application/json"
    } -UseBasicParsing | Out-Null
    $StatusCode = $LastStatusCode
    Write-Host $StatusCode

    Write-Host -NoNewline "GET : ${URL} - HTTP status = "
    $IPADDRESS = Get-Random -Minimum 0 -Maximum 255
    $IPADDRESS = "$IPADDRESS.$IPADDRESS.$IPADDRESS.$IPADDRESS"
    Invoke-RestMethod -Uri "${URL}/api/pet/findByStatus?status=pending" -Method Get -Headers @{
        "X-Forwarded-For" = $IPADDRESS
        "User-Agent" = "ML-Requester"
        "accept" = "application/json"
        "content-type" = "application/json"
    } -UseBasicParsing | Out-Null
    $StatusCode = $LastStatusCode
    Write-Host $StatusCode

    Write-Host -NoNewline "GET : ${URL} - HTTP status = "
    $IPADDRESS = Get-Random -Minimum 0 -Maximum 255
    $IPADDRESS = "$IPADDRESS.$IPADDRESS.$IPADDRESS.$IPADDRESS"
    Invoke-RestMethod -Uri "${URL}/api/pet/findByStatus?status=sold" -Method Get -Headers @{
        "X-Forwarded-For" = $IPADDRESS
        "User-Agent" = "ML-Requester"
        "accept" = "application/json"
        "content-type" = "application/json"
    } -UseBasicParsing | Out-Null
    $StatusCode = $LastStatusCode
    Write-Host $StatusCode
}

Write-Host "-------------------------------------------------------------------------------------------"
Write-Host "FortiWeb ML-API trained with GET method on ${URL}/"
Write-Host "-------------------------------------------------------------------------------------------"
