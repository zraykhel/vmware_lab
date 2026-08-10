#!/bin/bash

### Run with sudo
### Test setup and scan automation script
### $IP is a placeholder for lab victim machine IP address

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

# Create a special dictionary
echo "secret.html" > list.txt 

# Run nmap
nmap -sT -p80 -T4 $IP -o scan.txt >/dev/null 2>&1 && echo "[*] Running nmap scan..."
sleep 3
echo "[V] Nmap scan complete"
sleep 3

# Check scan result for open HTTP port
echo "[*] Checking if HTTP port is open..."
sleep 2

if grep http scan.txt; then
	echo "[V] HTTP port open"
else
	echo "[X] Port 80 closed"
	exit 1
fi
sleep 2

# Run gobuster enumeration
echo "[*] Running gobuster enumeration..."
gobuster dir -u http://$IP -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -r -t 200 -o dir_enum.txt >/dev/null 2>&1
echo "[V] Gobuster enumeration complete"
sleep 2
 
# Check for /secret directory
echo "[*] Checking for /secret directory..."
sleep 2
if grep secret dir_enum.txt; then
	echo "[V] Found /secret directory"
else
	echo "[X] /secret not found"
	exit 1
fi
    
# Run gobuster enumeration against /secret directory
sleep 2
echo "[*] Running second gobuster enumeration..."
gobuster dir -u http://$IP/secret/ -w /home/kali/list.txt -r -x html -o dir_enum2.txt >/dev/null 2>&1
echo "[V] Second gobuster enumeration complete"

# Check for secret.html
sleep 2
echo "[*] Checking for secret.html page..."

if grep 'secret.html' dir_enum2.txt; then
	echo "[V] Found secret.html page"
else
	echo "[X] secret.html not found"
	exit 1
fi
sleep 3

# Curl the page
echo "[*] Retrieving secret.html page contents, see contents below..."
curl http://$IP/secret/secret.html

# Finish the script
echo "[V] Script complete, congratulations!"
sleep 3
