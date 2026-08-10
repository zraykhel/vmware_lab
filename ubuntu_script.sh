#!/bin/bash

### Run with sudo
### Test setup automation script

# Prompt to check if run with sudo
echo "The script should be run with sudo rights, otherwise it will fail. Did you run it with sudo?"
echo
while true; do
	echo "1) Yes (continues execution)"
	echo "2) No (kills the script)"
	echo
	read -p "Select 1 or 2 and press Enter: " choice

	case "$choice" in
    	1)
        	echo
        	echo "Continuing execution..."
        	echo
        	break
        	;;
    	2)
        	echo
        	echo "Exiting..."
        	echo 
        	exit 0
        	;;
    	*)
        	echo
        	echo "Selection not detected, select again"
        	echo
        	;;
	esac
done

# Package update
echo "[!] Running package update..."
{
apt update
apt upgrade -y
apt autoremove -y
} >/dev/null 2>&1
echo "[V] Package update complete!"
sleep 5

# Apache2 HTTP Web Server installation
echo "[!] Installing apache2 and curl..."
apt install apache2 curl sl -y >/dev/null 2>&1
echo "[V] Apache and curl installation complete!"
sleep 5

# Checking if the server auto-started and starting if not

echo "[!] Checking HTTP server status..."
apache_status() {
SERVICE="apache2"
MAX_RETRIES=5
SLEEP_SECONDS=3

retries=0
while true; do
 if systemctl show -p LoadState --value "$SERVICE" 2>/dev/null | grep -qx 'loaded' && systemctl is-active --quiet "$SERVICE"; then
  echo "  [V] The HTTP server is online!"
  break
 fi

 echo "	[*] The server is offline, trying to start. Attempt $((retries+1))/$MAX_RETRIES ..."
 if ! systemctl enable "$SERVICE" >/dev/null 2>&1; then
  echo "  [*] Enable failed"
 fi	
		
 if ! systemctl start "$SERVICE" >/dev/null 2>&1; then
  echo "  [*] Start failed"
 fi

((retries++))
 if (( retries >= MAX_RETRIES )); then
  echo "  [X] Error: Reached max retries ($MAX_RETRIES)" >&2
  return 1
 fi

sleep "$SLEEP_SECONDS"
done
}

apache_status
sleep 5

# Creating another directory with one more page
echo "[*] Creating another directory with a new html page"
mkdir /var/www/html/secret
echo '<html>Hello, world!</html>' > /var/www/html/secret/secret_page.html
sleep 3
echo "[*] Testing page availability. See the page contents below:"
curl http://localhost:80/secret/secret_page.html
sleep 5
echo "[!] Setup complete!"
sleep 5
sl
