#!/bin/bash
#
# Script para generación de tráfico random contra una aplicación DVWA
# - El script es capaz de establecer la cookie de sesión contra el servidor
# - Tiene un menú contextual para realizar todos los pasos
#
####################################################################

# Credenciales de login
username="admin"
password="password"

# Número de repeticiones
n=50  # Puedes cambiar esto para hacer más repeticiones
debug=0

# Check if public IP is provided as a command-line argument
if [ -z "$1" ]; then
    # Ask for the public IP of the site if not provided
    read -p "IP o dominio DVWA publicado: " public_ip
else
    # Use the provided argument as the public IP
    public_ip="$1"
fi

# Check if public IP is provided as a command-line argument
if [ -z "$2" ]; then
    read -p "Puerto de la aplicación (ex. 31010): " port
else
    port="$2"
fi

dvwa_host="$public_ip:$port"

# Array con las URIs de DVWA
uris=(
    "/index.php"                # Página principal / login
    "/vulnerabilities/brute/"    # Fuerza bruta
    "/vulnerabilities/csrf/"     # CSRF
    "/vulnerabilities/exec/"     # Inyección de comandos
    "/vulnerabilities/sqli/"      # Inyección SQL
    "/vulnerabilities/sqli_blind/" # Inyección SQL ciega
    "/vulnerabilities/xss_r/"    # XSS reflejado
   "/vulnerabilities/xss_s/"    # XSS almacenado
    "/vulnerabilities/upload/"    # Subida de archivos
   "/setup.php"                 # Configuración inicial
    "/security.php"              # Configuración de seguridad
    "/phpinfo.php"               # Información PHP
    "/instructions.php"           # Instrucciones de uso
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



# Función para hacer login y capturar sesion de DVWA
login_dvwa() {
   
# Archivo temporal para almacenar cookies
cookie_file=$(mktemp)

# Paso 1: Obtener la página de login para capturar el 'user_token'
login_page=$(curl -s -c "$cookie_file" "$dvwa_host/login.php")

# Capturar el user_token usando awk
user_token=$(echo "$login_page" | awk -F"'" '/user_token/ {print $6}')

# Verificar si se ha capturado el token
if [ -z "$user_token" ]; then
    echo "Error: No se pudo capturar el user_token."
    exit 1
fi

echo "user_token capturado: $user_token"


# Buscar JSESSIONID o PHPSESSID en el archivo de cookies
    if grep -q 'JSESSIONID' "$cookie_file"; then
        session_name="JSESSIONID"
        
    elif grep -q 'PHPSESSID' "$cookie_file"; then
        session_name="PHPSESSID"
       
    else
        echo "Error: No se encontró ni JSESSIONID ni PHPSESSID en el archivo de cookies."
        return 1
    fi


# Paso 2: Hacer login enviando las credenciales, el user_token y la cookie de sesión
login_response=$(curl -s -b "$cookie_file" -c "$cookie_file" -X POST "$dvwa_host/login.php" \
    -d "username=$username" \
    -d "password=$password" \
    -d "user_token=$user_token" \
    -d "Login=Login")

# Verificar si el login fue exitoso buscando la cookie de sesión PHPSESSID
session_id=$(grep 'PHPSESSID' "$cookie_file" | awk '{print $7}')
if [ -z "$session_id" ]; then
    echo "Error: No se pudo capturar el PHPSESSID. Verifica las credenciales o la configuración de DVWA."
    exit 1
fi

echo "Login exitoso. Session ID: $session_id"

# Puedes ahora realizar más peticiones a DVWA utilizando la cookie de sesión almacenada en $cookie_file



    
    
    
}



# Función para hacer las llamadas a las URIs
function make_requests() {
    
    
    read -p "Número de repeticiones: " n
  
    
    for ((i=1; i<=n; i++)); do
        echo "Iteración $i de $n"
        
        if [ $debug -eq 0 ]; then
            printf "Peticion:"
        fi 
        
        for uri in "${uris[@]}"; do
       
            # Pick a random User-Agent from the array
            random_user_agent="${user_agents[$RANDOM % ${#user_agents[@]}]}"="${user_agents[$RANDOM % ${#user_agents[@]}]}"
            
            # Generate a random IP
            random_ip=$(generate_random_ip)
            if [ $debug -eq 1 ]; then
                echo "Random IP:"$random_ip
                echo "User_agent:"$random_user_agent
            fi
            
            

        
            local full_url="$dvwa_host$uri"
            if [ $debug -eq 1 ]; then
                printf "Haciendo llamada a: %s\n" "$full_url"
                echo 'curl -s -o /dev/null -w "Codigo HTTP:%{http_code}\n" -A "$random_user_agent"  "$full_url" -H "Cookie: $session_name=$session_id; ; security=low" -H "X-Forwarded-For: $random_ip"'
                curl -s -o /dev/null -w "Codigo HTTP:%{http_code}\n" -A "$random_user_agent"  "$full_url" -H "Cookie: $session_name=$session_id; ; security=low" -H "X-Forwarded-For: $random_ip"
                printf "\n"  # Añadir una línea en blanco entre las respuestas
                
            else    
                printf "."
                curl -s -o /dev/null -A "$random_user_agent"  "$full_url" -H "Cookie: $session_name=$session_id; ; security=low" -H "X-Forwarded-For: $random_ip" 
            fi
            
            
            sleep 0.5
        done
    done
}


# Pausa después de ejecutar una función
pausa() {
    printf "\n"
    read -p "Presiona [Enter] para volver al menú..."
    printf "\n"
}

# Menú principal
mostrar_menu() {
    local public_ip=$1
    local port=$2
    
    rojo='\e[1;31m'
    verde='\e[1;32m'
    amarillo='\e[1;33m'
    limpiar='\e[0m'

    clear
    printf "*****************************\n"
    printf "        Menú Principal       \n"
    printf "*****************************\n"
    printf " IP:%s     port:%s           \n" "$public_ip" "$port"
    printf "$verde Session Name: %s     $amarillo Session ID: %s           $limpiar \n" "$session_name" "$session_id"
    if [ $debug -eq 1 ]; then
        printf "$rojo Debug: Activado $limpiar\n"
    fi
    printf "*****************************\n"
    
    
    if [ -z "$session_id" ]; then
        # Ask for the public IP of the site if not provided
        printf "1. Ejecutar captura session\n"
        printf "Selecciona una opción [1]: "
    else
        printf "2. Ejecutar Adaptative Learning\n"
        printf "3. Activar debug \n"
        printf "4. Desactivar debug\n"
        printf "5. Inyeccion SQL\n"
        printf "6. Salir\n"
        printf "*****************************\n"
        printf "Selecciona una opción [2-6]: "
    fi
        
    read opcion
}


inyection_SQL(){

local sql_payload="1' OR '1'='1"
local full_url="$dvwa_host/vulnerabilities/sqli/"

# Pick a random User-Agent from the array
random_user_agent="${user_agents[$RANDOM % ${#user_agents[@]}]}"="${user_agents[$RANDOM % ${#user_agents[@]}]}"
            
# Generate a random IP
random_ip=$(generate_random_ip)
if [ $debug -eq 1 ]; then
    echo "Random IP:"$random_ip
    echo "User_agent:"$random_user_agent
fi

if [ $debug -eq 1 ]; then
    printf "Haciendo llamada a: %s\n" "$full_url"
    curl -s -o /dev/null -w "Codigo HTTP:%{http_code}\n" -A "$random_user_agent"  "$full_url" --data "id=$sql_payload&Submit=Submit" -H "Cookie: $session_name=$session_id; ; security=low" -H "X-Forwarded-For: $random_ip"
    printf "\n"  # Añadir una línea en blanco entre las respuestas
    else    
    printf "."
    curl -s -o /dev/null -A "$random_user_agent"  "$full_url" --data "id=$sql_payload&Submit=Submit" -H "Cookie: $session_name=$session_id; ; security=low" -H "X-Forwarded-For: $random_ip" 
fi
            
}








# Bucle para mostrar el menú y ejecutar funciones
while true; do
    mostrar_menu $public_ip $port
    case $opcion in
        1)
            login_dvwa 
            pausa
            ;;
        2)
            # make_requests $session_id $session_name $public_ip
            make_requests

            pausa
            ;;
        3)
            debug=1
            pausa
            ;;
        4)
            debug=0
            pausa
            ;;
        
        5)
            inyection_SQL
            pausa
            ;;
            
        6)
            printf "\nSaliendo del programa. ¡Hasta luego!\n"
            rm $cookie_file
            exit 0
            ;;
        *)
            printf "\nOpción no válida. Intenta de nuevo.\n"
            pausa
            ;;
    esac
done





