#!/bin/bash

function nmap_analyze(){
	port=$1
	if [ ! -d "$default_path2/$domain_name/nmap" ]; then
		mkdir -p "$default_path2/$domain_name/nmap"
	fi

	if [ ! -d "$default_path2/$domain_name/nmap/$port" ]; then
		mkdir -p "$default_path2/$domain_name/nmap/$port"
	fi

	# Retrieve IP list of open ports from masscan results
	find  "$default_path2/$domain_name/masscan/$port" -type f | grep -v "$port.txt" | cut -d '/' -f 9 | cut -d '_' -f 2 | sort > "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"

	while read ip; do
		echo -e "\n${turquoiseColour}Scanning${endColour}${redColour} $ip${endColour}${turquoiseColour} with nmap${endColour}"
		nmap -p $port -Pn -T3 -sS -sV -O -v "$ip" -oN "$default_path2/$domain_name/nmap/$port/${domain_name}_${ip}_scan.txt"
		#echo -e \n"nmap -p $port -sV -O $ip -oG $default_path2/$domain_name/nmap/$port/${domain_name}_${ip}_scan.txt"

		# Check if the port is open using grep
		echo -e "$default_path2/$domain_name/nmap/$port/${domain_name}_${ip}_scan.txt"
		if grep -q "open" "$default_path2/$domain_name/nmap/$port/${domain_name}_${ip}_scan.txt"; then
			echo -e "${greenColour}Port $port found open for $ip${endColour}"
		else
			echo -e "${redColour}Port $port not found open for $ip${endColour}"
			rm "$default_path2/$domain_name/nmap/$port/${domain_name}_${ip}_scan.txt" 2>/dev/null
		fi
	done < "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"

}

