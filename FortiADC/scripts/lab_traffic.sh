####################################################################
#!/bin/bash
#
# Script para generación de tráfico random contra una aplicación DVWA
# - El chequeo se realiza de forma infinita contra un listado de IPs
#
####################################################################

# Variables
port="31010"

# Define a list of publics IP to check
public_ips=(
34.250.206.149
18.132.56.104
15.236.220.91
)

# Define an array of URL paths to request
url_paths=(
    "/instructions.php" 
    "/setup.php" 
    "/vulnerabilities/brute/" 
    "/vulnerabilities/exec/"
    "/vulnerabilities/csrf/"
    "/vulnerabilities/upload/"
    "/vulnerabilities/captcha/"
    "/vulnerabilities/sqli/"
    "/vulnerabilities/sqli_blind/"
    "/vulnerabilities/weak_id/"
    "/vulnerabilities/xss_d/"
    "/vulnerabilities/xss_r/"
    "/vulnerabilities/xss_s/"
    "/vulnerabilities/csp/"
    "/vulnerabilities/javascript/"
    "/security.php"
    "/phpinfo.php"
    "/about.php"
)

# Define an array of real User-Agent strings
user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
    "Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36"
)

# Function to generate a random IP address
generate_random_ip() {
    echo "$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256))"
}

# Infinite loop to make HTTP requests to the site
while true; do
    for public_ip in "${public_ips[@]}"; do
        echo "Generating requests to http://$public_ip:$port ..."
        # Loop through each URL path
        for path in "${url_paths[@]}"; do
            # Generate a random IP
            random_ip=$(generate_random_ip)

            # Pick a random User-Agent from the array
            random_user_agent="${user_agents[$RANDOM % ${#user_agents[@]}]}"

            # Make the HTTP request with curl, including the X-Forwarded-For header
            curl --max-time 1 -H "X-Forwarded-For: $random_ip" -A "$random_user_agent" -s -o /dev/null "http://$public_ip:$port$path"

            # Check the exit status of curl to see if the request was successful
            if [ $? -ne 0 ]; then
                echo "Error: Unable to connect to $public_ip$path"
                # Skip to the next random IP (break out of the URL path loop)
                break
            fi

            # Optional: Sleep for 1 second between requests to avoid overwhelming the server
            #sleep 1
        done
    done
done

