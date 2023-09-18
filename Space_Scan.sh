#!/bin/bash

#Colours
orangeColour="\e[0;32m\033[1m"
greenColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
purpleColour="\e[0;34m\033[1m"
grayColour="\e[0;37m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
endColour="\033[0m"

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c() {
	echo -e "\n${redColour}Received Ctrl+C, cleaning up...${endColour}"
    kill "${xterm_pids[@]}" 2>/dev/null
    echo -e "\n${redColour}[!] Exiting...\n${endColour}"
    tput cnorm; 
    exit 1
}


function helpPanel(){
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n${purpleColour}This program automates scanning tools usage${endColour}" 
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n${turquoiseColour} [!] Usage:${endColour} ${orangeColour}sudo ./Space_Scan.sh -d [domain]${endColour}"
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n\t${orangeColour}-d\t--domain\t\t${endColour}${turquoiseColour} Receives main domain${endColour}"
	echo -e "\t${orangeColour}-l\t--list\t\t\t${endColour}${turquoiseColour} Receives list of main domains${endColour}"
	echo -e "\t${orangeColour}-s\t--subfinder\t\t${endColour}${turquoiseColour} Run subfinder${endColour}"
	echo -e "\t${orangeColour}-o\t--dns-resolution\t${endColour}${turquoiseColour} Run dns resolution${endColour}"
	echo -e "\t${orangeColour}-m\t--masscan-analyze\t${endColour}${turquoiseColour} Analyze clean IP's with masscan${endColour}"
	echo -e "\t${orangeColour}-n\t--nmap-analyze\t\t${endColour}${turquoiseColour} Analyze clean IP's with nmap${endColour}"
	echo -e "\t${orangeColour}-i\t--nuclei-analyze\t${endColour}${turquoiseColour} Analyze clean IP's with nuclei${endColour}"
	echo -e "\t${orangeColour}-a\t--analyze-masscan\t${endColour}${turquoiseColour} Analyze masscan results${endColour}"
	echo -e "\t${orangeColour}-r\t--recursive\t\t${endColour}${turquoiseColour} Execute recursive commands${endColour}"
	echo -e "\t${orangeColour}-t\t--mode\t\t\t${endColour}${turquoiseColour} Setup mode options: [weak, medium, strong]${endColour}"
	echo -e "\t${orangeColour}-w\t--windows\t\t${endColour}${turquoiseColour} Setup how many windows will be opened simultaneously${endColour}"
	echo -e "\t${orangeColour}-h\t--help\t\t\t${endColour}${turquoiseColour} Show this help message${endColour}"
	echo -e "\n\t${orangeColour}Examples:\t${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -s${endColour} 1 -o"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -m${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -a${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s 1 -o\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s 1 -o -m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -n 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -i 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -w${endColour} 4${orangeColour} -t${endColour} weak${orangeColour} -i${endColour} 80"

	exit 1
}

# This is the default path where the images will be saved.
default_path="home/grimaldi/Bash/Space_Scan"
cd /
if [ ! -d "$default_path" ]; then
	mkdir -p $default_path
fi

default_path2="$default_path/targets"
if [ ! -d "$default_path2" ]; then
	mkdir -p $default_path2
fi

# Receives new path
function change_Path() {
	default_path=$1
	if [ ! -d "$default_path" ]; then
		mkdir -p $default_path
	fi

	default_path2="$default_path/targets"
	if [ ! -d "$default_path2" ]; then
		mkdir -p $default_path2
	fi
}

function mode() {
	temp_mode=$1
}

function windows() {
	if [ "$max_xterms" -gt 8 ]; then
		echo "The total number of windows cannot be greater than 8"
	fi
}

function subfinder_fetch() {
	enable_subfinder=$1
	if [ "$enable_subfinder" = "1" ]; then
		if [ ! -d "$default_path2/$domain_name" ]; then
			mkdir -p "$default_path2/$domain_name"
			echo -e "Successful directory creation at $default_path2/$domain_name"
		fi
		subfinder -d "$domain_name" | tee "$default_path2/$domain_name/$domain_name.txt"
		echo "Subdomains fetched -> /$default_path2/$domain_name/$domain_name.txt"
	fi
}

function dns_resolution() {
	cont=1
	while read url; do
		echo -e "${orangeColour}$cont${endColour}${greenColour} resolving ${endColour}${turquoiseColour}$url${endColour}"
		result=$(dig +short "$url" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
		if [ -n "$(echo $result)" ]; then
			echo "$result" | sed "s/^/$url -> /" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$default_path2/$domain_name/${domain_name}_IPs_correlated.txt"
			echo "$result" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$default_path2/$domain_name/${domain_name}_IPs_clean.txt"
		fi
		let cont+=1
	done < "$default_path2/$domain_name/$domain_name.txt"
	
	grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' "$default_path2/$domain_name/${domain_name}_IPs_clean.txt" | sort > "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt"

	grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' "$default_path2/$domain_name/${domain_name}_IPs_clean.txt" | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n -u > "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt"

	echo -e "\nDNS resolutions:" 
	echo -e "-> ${orangeColour}/$default_path2/$domain_name/${domain_name}_IPs_correlated.txt${endColour}"
	echo -e "-> ${orangeColour}/$default_path2/$domain_name/${domain_name}_IPs_clean.txt${endColour}"
	echo -e "-> ${orangeColour}/$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt${endColour}"
}

function masscan_analyze() {
	port=$1
	if [ ! -d "$default_path2/$domain_name/masscan" ]; then
		mkdir -p "$default_path2/$domain_name/masscan"
	fi
	if [ ! -d "$default_path2/$domain_name/masscan/$port" ]; then
		mkdir -p "$default_path2/$domain_name/masscan/$port"
	fi

	if [ "$port" == "all" ]; then
		shuf "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt" | head -n 5 | while read ip; do
			echo -e "\n${turquoiseColour}Scanning${endColour}${redColour} $ip${endColour}${turquoiseColour} with masscan${endColour}"
			masscan -p1-65535 "$ip" -oG "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt"
		done
	else
		while read ip; do
			echo -e "\n${turquoiseColour}Scanning${endColour}${redColour} $ip${endColour}${turquoiseColour} with masscan${endColour}"
			masscan -p"$port" "$ip" -oG "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt"
			#scan_output=$(masscan -p"$port" "$ip" -oG "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt")

			if echo  "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt"| grep -q "open"; then
				echo "Port $port found for $ip"
			else
				echo "Port $port not found for $ip"
				if [ ! -s "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt" ]; then
					rm "$default_path2/$domain_name/masscan/$port/${domain_name}_${ip}_scan.txt"
				fi
			fi
		done < "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt"
	fi
}

function masscan_analyze_scans() {
	port=$1

	if [ "$port" = "all" ]; then
		results=$(find $default_path -wholename "*masscan/$port/$domain_name*" | grep -v "analysis" | xargs cat | grep Ports:)	
		lines=$(echo "$results" | wc -l)

		if [ -e "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt" ]; then
			rm "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt"
		fi

		for line in $(seq 1 "$lines"); do
			echo "$results" | awk "NR==$line" | awk '{print $7}' 
		done | sort -k2,2n | uniq | tee "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt"

		echo -e "\n${redColour}Results saved${endColour} -> ${turquoiseColour}/$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt${endColour}"
	else
		results=$(find $default_path -wholename "*masscan/$port/$domain_name*" | grep -v "analysis" | xargs cat | grep Ports:)	
		lines=$(echo "$results" | wc -l)

		if [ -e "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt" ]; then
			rm "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt"
		fi

		for line in $(seq 1 "$lines"); do
			echo "$results" | awk "NR==$line" | awk '{print $7}' 
		done | sort -k2,2n | uniq | tee "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt"
		
		echo -e "\nTotal IP's with ${redColour}$port${endColour} Port Open -> ${turquoiseColour}$(cat "$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt" | wc -l)${endColour}"

		echo -e "\n${redColour}Results saved${endColour} -> ${turquoiseColour}/$default_path2/$domain_name/masscan/$port/${domain_name}_analysis.txt${endColour}"
	fi

}

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


function nuclei_analyze(){
	port=$1
	if [ ! -d "$default_path2/$domain_name/nuclei" ]; then
		mkdir -p "$default_path2/$domain_name/nuclei"
	fi

	if [ ! -d "$default_path2/$domain_name/nuclei/$port" ]; then
		mkdir -p "$default_path2/$domain_name/nuclei/$port"
	fi
	
	if [ ! -e "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt" ]; then
		# Retrieve IP list of open ports from masscan results
		find  "$default_path2/$domain_name/masscan/$port" -type f | grep -v "$port.txt" | cut -d '/' -f 9 | cut -d '_' -f 2 | sort > "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"
	fi

	width_const=6
	height_const=12

	width_max=1366
	height_max=768

	window_width=50
	window_height=80


	columns=$((width_max / (window_width)))
	rows=$((($lines_global + columns - 1) / columns))
	
	private_counter=1

	if [ "$port" = "80" ]; then

		if [ "$global_mode" == "strong" ]; then
			echo -e "\nLoading ${turquoiseColour}High, Critical${endColour} templates to use it."
			nuclei -tl -s high,critical -pt http 2>/dev/null > "$default_path2/$domain_name/nuclei/$port/nuclei-templates.txt"

		elif [ "$global_mode" == "weak" ]; then
			echo -e "\nLoading ${turquoiseColour}Info, Low${endColour} templates to use it."
			nuclei -tl -s info,low -pt http 2>/dev/null > "$default_path2/$domain_name/nuclei/$port/nuclei-templates.txt"

		elif [ "$global_mode" == "medium" ]; then
			echo -e "\nLoading ${turquoiseColour}Info, Low, Medium${endColour} templates to use it."
			nuclei -tl -s medium -pt http 2>/dev/null > "$default_path2/$domain_name/nuclei/$port/nuclei-templates.txt"

		else
			echo "Select a valid option for mode."
		fi

			
		while read ip; do
			if [ ! -d "$default_path2/$domain_name/nuclei/$port/$ip" ]; then
				mkdir -p "$default_path2/$domain_name/nuclei/$port/$ip"
			fi

			echo -e "\n${turquoiseColour}Scanning${endColour}${redColour} $ip${endColour}${turquoiseColour} with nuclei${endColour}"
			grep $ip "$default_path2/${domain_name}/${domain_name}_IPs_correlated.txt" | cut -d ' ' -f 1 > "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.txt"

			if [ -e "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh" ]; then
				rm "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			fi
			touch "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			chmod +x "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"

			echo "#!/bin/bash" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "orangeColour=\"\e[0;32m\033[1m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh" 
			echo "greenColour=\"\033[0m\e[0m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "redColour=\"\e[0;31m\033[1m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "purpleColour=\"\e[0;34m\033[1m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "grayColour=\"\e[0;37m\033[1m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "turquoiseColour=\"\e[0;36m\033[1m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "endColour=\"\033[0m\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "counter=0" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"

			while read subdomain; do
				while read template; do
					echo -e "\nlet counter+=1" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e 'echo -e "\n${greenColour}Running $counter attempt:${endColour}"' >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "echo -e \"\${turquoiseColour}sudo nuclei -t /home/grimaldi/.local/nuclei-templates/$template -target $ip $subdomain 2>/dev/null | sudo tee /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\${endColour}\"\n" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "sudo nuclei -t /home/grimaldi/.local/nuclei-templates/$template -target $ip $subdomain 2>/dev/null | sudo tee /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					
					echo -e "		if [ -e \"/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\" ]; then" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "			if [ ! -s \"/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\" ]; then" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "				rm \"/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "				echo \"Successfully deleted /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\"" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "			fi" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "		fi" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"


					if [ -e "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}.${subdomain}_${ip}.txt" ]; then
						if [ ! -s "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}.${subdomain}_${ip}.txt" ]; then
							rm "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}.${subdomain}_${ip}.txt"
						fi
					fi
				done < "$default_path2/$domain_name/nuclei/$port/nuclei-templates.txt"
		

				# Start new xterm windows if someones already finished
				if [ "$running_xterms" -ge "$max_xterms" ]; then
					running_xterms=0
				fi

				# dimensions of my current display:    1366x768 pixels (361x203 millimeters)
				x_offset=$((running_xterms % columns * (window_width * width_const)))
				cocient=$((x_offset / width_max))
				x_offset=$((x_offset - (cocient * width_max)))
				if ((x_offset < window_width * width_const)); then
					variance="$x_offset"
				fi
				x_offset=$((x_offset - variance))
				y_offset=$((cocient * window_height * height_const))

				#echo "max_xterms: $max_xterms		xterm_counter=$xterm_counter"
				if [[ $((max_xterms - xterm_counter)) -ge 1 ]]; then
					xterm -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e "bash $default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh" &
					#xterm  -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e 'for i in {1..10}; do echo "$i"; sleep 1; done' &
					xterm_pids+=($!)
					echo "$private_counter		|		$domain_name		|		$subdomain"
					((running_xterms++))
					((xterm_counter++))
					((private_counter++))
				else
					if [ "${#xterm_pids[@]}" -gt 0 ]; then
						echo -e "${redColour}\nWaiting other xterm windows to finish...${endColour}"
						wait "${xterm_pids[0]}"
						unset xterm_pids[0]  # Remove the finished xterm PID from the array
						xterm_pids=("${xterm_pids[@]}")  # Reindex the array
						((xterm_counter--))


						xterm -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e "bash $default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh" &
						#xterm  -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e 'for i in {1..10}; do echo "$i"; sleep 1; done' &
						xterm_pids+=($!)
						echo "$private_counter		|		$domain_name		|		$subdomain"
						((running_xterms++))
						((xterm_counter++))
						((private_counter++))

						else
							echo "No xterm windows to wait for."
							xterm_counter=0
					fi
				fi

				while read template; do
					if [ -e "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt" ]; then
						if [ ! -s "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt" ]; then
							rm "/$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt"
							echo "Successfully deleted /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt"
						fi
					fi
				done < "$default_path2/$domain_name/nuclei/$port/nuclei-templates.txt"


			done < "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.txt"


		done < "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"
	
		date=$(date)
		echo "This IP was scanned with the nuclei-templates.txt at: $date" > "$default_path2/$domain_name/nuclei/$port/$ip/Finished.txt"

	fi
}



# Global variables
recursive_string_global="h"
recursive_counter=0
lines_global=3
x_offset=0
y_offset=0
global_mode=0
max_xterms=$((4+1))
running_xterms=0
xterm_counter=0

function iterate_domains() {
	domain_list=$1
	cd $default_path

	lines=$(cat "/$default_path/$domain_list" | wc -l)
	lines_global="$lines"
	for line in $(seq 1 "$lines"); do
		domain=$(cat "/$default_path/$domain_list" | awk "NR==$line")
		let recursive_counter+=1
		recursive_command $domain 
	done
	while true; do
		sleep 1
	done
}

function recursive_command() {
	width_const=6
	height_const=12

	width_max=1366
	height_max=768

	window_width=50
	window_height=30


	columns=$((width_max / (window_width)))
	rows=$((($lines + columns - 1) / columns))

	if [ ! "$recursive_counter" = "0" ]; then
		domain=$1
		recursive_string="./Space_Scan.sh -d $domain $recursive_string_global"
		echo "$recursive_string"

		# dimensions of my current display:    1366x768 pixels (361x203 millimeters)
		x_offset=$(((recursive_counter-1) % columns * (window_width * width_const)))
		
		cocient=$((x_offset / width_max))
		x_offset=$((x_offset - (cocient * width_max)))
		if ((x_offset < window_width * width_const)); then
			variance="$x_offset"
			#echo -e "${redColour}Variance: $variance${endColour}"
		fi
		x_offset=$((x_offset - variance))
		y_offset=$((cocient * window_height * height_const))

		xterm -hold -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e "$recursive_string" &
		xterm_pids+=($!)
		#echo -e "xterm -hold -geometry ${redColour}${window_width}x${window_height}+${x_offset}+${y_offset}${endColour} -e \"$recursive_string\"\n"

	fi
}


# Main Function
xterm_pids=()
counter=0

ARGS=$(getopt -o d:l:s:ot:w:m:n:i:a:r:h --long domain:,list:,subfinder:,dns-resolution,mode:,windows:,masscan-analyze:,nmap-analyze,nuclei-analyze,analyze-masscan,recursive:,help -n "$0" -- "$@")
eval set -- "$ARGS"

while true; do
    case "$1" in
        -d|--domain)
            domain_name="$2"
            counter=$((counter + 1))
            shift 2
            ;;
        -l|--list)
            domain_list="$2"
            iterate_domains "$domain_list"
            counter=$((counter + 1))
            shift 2
            ;;
        -s|--subfinder)
            enable_subfinder="$2"
            subfinder_fetch "$enable_subfinder"
            counter=$((counter + 1))
            shift 2
            ;;
        -o|--dns-resolution)
            dns_resolution
            counter=$((counter + 1))
            shift
            ;;
        -t|--mode)
            global_mode="$2"
			mode "$global_mode" 
            counter=$((counter + 1))
            shift 2
            ;;
        -w|--windows)
            max_xterms="$2"
			windows "$max_xterms" 
            counter=$((counter + 1))
            shift 2
            ;;
        -m|--masscan-analyze)
            port="$2"
            masscan_analyze "$port"
            counter=$((counter + 1))
            shift 2
            ;;
        -n|--nmap-analyze)
			port="$2"
			shift
            nmap_analyze "$port"
            counter=$((counter + 1))
            shift
            ;;
        -i|--nuclei-analyze)
			port=$2
			shift
            nuclei_analyze $port
            counter=$((counter + 1))
            shift
            ;;
        -a|--analyze-masscan)
            port="$2"
            masscan_analyze_scans "$port"
            counter=$((counter + 1))
            shift 2
            ;;
		-r|--recursive)
			recursive_string_global="$2"
			shift
			echo "$recursive_string"
			recursive_command "$recursive_string"
            counter=$((counter + 1))
			shift 
            ;;
        -h|--help)
            helpPanel
            ;;
        --)
            shift
            break
            ;;
        *)
            helpPanel
            echo -e "\n${redColour}[!] Invalid option. Exiting...\n${endColour}"
            exit 1
            ;;
    esac
done

# Restore cursor and show help if no options were provided
tput cnorm
if [ "$counter" -eq 0 ]; then
    helpPanel
fi

