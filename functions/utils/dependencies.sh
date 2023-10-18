#!/bin/bash

function dependencies() {
	tput civis
	dependencies=(subfinder dnsutils whois sqlite3 masscan nmap nuclei)
	echo -e "${redColour}[*] ${endColour}${turquoiseColour}Checking necessary programs...${endColour}"

	for program in "${dependencies[@]}"; do
		echo -ne "\n${redColour}[*] ${endColour}${yellowColour}Tool: ${endColour}${purpleColour}$program${endColour}"

		test -f "/usr/bin/$program"
		if [ "$(echo $?)" -eq "0" ]; then
			echo -e "${turquoiseColour} (V)${endColour}"
		else
			echo -e "${turquoiseColour} (X)${endColour}"
			echo -e "Installing tool ${turquoiseColour}$program${endColour}..."
			apt install "$program" -y > /dev/null 2>&1
		fi
	done; sleep 1
	
}

