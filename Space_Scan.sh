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

    #kill "${xterm_pids[@]}" 2>/dev/null

	# Kill all xterm processes and their children
    for pid in "${xterm_pids[@]}"; do
        pkill -P "$pid"
    done

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
	echo -e "\t${orangeColour}-t\t--mode\t\t\t${endColour}${turquoiseColour} Setup nuclei mode options: [weak, weak-fast, medium, strong, latest]${endColour}"
	echo -e "\t${turquoiseColour}\tweak\t\t\t${endColour}${turquoiseColour} Use the weak severity templates from nuclei ${endColour}"
	echo -e "\t${turquoiseColour}\tweak-fast\t\t\t${endColour}${turquoiseColour} Use the most common weak severity templates from nuclei ${endColour}"
	echo -e "\t${turquoiseColour}\tmedium\t\t\t${endColour}${turquoiseColour} Use the medium severity templates from nuclei ${endColour}"
	echo -e "\t${turquoiseColour}\tstrong\t\t\t${endColour}${turquoiseColour} Use the high and critical severity templates from nuclei ${endColour}"
	echo -e "\t${turquoiseColour}\tlatest\t\t\t${endColour}${turquoiseColour} Use the latest templates from nuclei ${endColour}"
	echo -e "\t${orangeColour}-w\t--windows\t\t${endColour}${turquoiseColour} Setup how many windows will be opened simultaneously${endColour}${turquoiseColour}  ${endColour}"
	echo -e "\t${orangeColour}-h\t--help\t\t\t${endColour}${turquoiseColour} Show this help message${endColour}${turquoiseColour}  ${endColour}"
	echo -e "\n\t${orangeColour}Examples:\t${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -s${endColour} 1 -o"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -m${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -a${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s 1 -o\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s 1 -o -m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -n 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -i 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -w${endColour} 4${orangeColour} -m${endColour} 80"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -w${endColour} 4${orangeColour} -t${endColour} weak${orangeColour} -i${endColour} 80"

	exit 1
}


# Get the username of the normal user or the sudo user if empty
if [ -n "$SUDO_USER" ]; then
    username="$SUDO_USER"
else
    username="$USER"
fi

# Check if the username is empty (indicating that sudo was not used)
if [ -z "$username" ]; then
    echo "Unable to determine the username. Please run this script with sudo."
    exit 1
fi

# This is the default path where the images will be saved.
default_path="home/$username/Bash/Space_Scan"
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
	max_xterms=$1
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
		echo
		echo -e "${turquoiseColour}Subdomains fetched -> /$default_path2/$domain_name/$domain_name.txt${endColour}"
		echo
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
			echo -n "$result" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}'
			echo
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
	if [ ! -d "$default_path2/$domain_name/masscan/$port/$ip" ]; then
		mkdir -p "$default_path2/$domain_name/masscan/$port/$ip"
	fi

	columns=$((width_max / (window_width)))
	rows=$((($lines_global + columns - 1) / columns))
	
	private_counter=1

	if [ "$port" == "all" ]; then

		echo -e "Scanning only${orangeColour} $max_xterms${endColour} IP's in range${orangeColour} 1-65535${endColour} from this file:"
		echo -e "${turquoiseColour}/$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt ${endColour}"
		echo -e "${grayColour}Total IP's:${endColour}		$max_xterms"
		echo -e "${grayColour}Parallel Windows:${endColour}	$max_xterms"
		echo -e "${grayColour}IP's per Window:${endColour} 	1"
		echo


		# Divide the IPs into smaller files
		lines_global=$(wc -l < "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt")
		split -d -l $((lines_global / max_xterms)) "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt" "$default_path2/$domain_name/masscan/$port/ip_chunk_"


		# Loop through the IP chunks and create scripts for each
		for chunk_file in "$default_path2/$domain_name/masscan/$port/ip_chunk_"*; do
			chunk_file_basename=$(basename "$chunk_file")

			if [ ! -d "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}" ]; then
				mkdir -p "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory"
				mv "$default_path2/$domain_name/masscan/$port/$chunk_file_basename" "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory"

				# Create a Masscan script for each chunk

				script_file="$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory/masscan_${chunk_file_basename}.sh"
				touch "$script_file" 2>/dev/null
				chmod +x "$script_file"

				# Create a Masscan script for each chunk
				cat <<EOF > "$script_file"
#!/bin/bash

orangeColour="\e[0;32m\033[1m"
greenColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
purpleColour="\e[0;34m\033[1m"
grayColour="\e[0;37m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
endColour="\033[0m"

# This counter is important, the else block bash script doesn't have this counter.
counter=1

for ip in \$(cat "/${chunk_file}_directory/${chunk_file_basename}"); do
	echo -e "\${turquoiseColour}Scanning\${endColour}\${orangeColour} \$ip\${endColour}\${turquoiseColour} with masscan ...\${endColour}" 
	masscan -p1-65535 "\$ip" -oG "$default_path2/$domain_name/masscan/$port/${domain_name}\${ip}_scan.txt" 
	let counter+=1
	if [ "$counter" -gt 1 ]; then
		break
	fi
done
EOF

				# dimensions of my current display:    1366x768 pixels (361x203 millimeters)
				x_offset=$((running_xterms % columns * (window_width * width_const)))
				cocient=$((x_offset / width_max))
				x_offset=$((x_offset - (cocient * width_max)))
				if ((x_offset < window_width * width_const)); then
					variance="$x_offset"
				fi
				x_offset=$((x_offset - variance))
				y_offset=$((cocient * window_height * height_const))

				if [[ $((max_xterms - xterm_counter)) -ge 1 ]]; then
					# Execute the script in the background
					xterm -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e "bash $script_file" &
					xterm_pids+=($!)
					((running_xterms++))
					((xterm_counter++))
					((private_counter++))
				fi


			fi
		done
				# Wait for all background processes (xterm processes) to finish
				wait "${xterm_pids[@]}"

	# Beginning of the else!
	else

		echo "Scanning all the IP's from this file:"
		lines=$(cat "/$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt" | wc -l)
		echo -e "${turquoiseColour}/$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt ${endColour}"
		echo -e "${grayColour}Total IP's:${endColour}		$lines"
		echo -e "${grayColour}Parallel Windows:${endColour}	$max_xterms"
		echo -e "${grayColour}IP's per Window:${endColour} 	$((lines/max_xterms))"
		echo

		# Divide the IPs into smaller files
		lines_global=$(wc -l < "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt")
		split -d -l $((lines_global / max_xterms)) "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt" "$default_path2/$domain_name/masscan/$port/ip_chunk_"


		# Loop through the IP chunks and create scripts for each
		for chunk_file in "$default_path2/$domain_name/masscan/$port/ip_chunk_"*; do
			chunk_file_basename=$(basename "$chunk_file")

			if [ ! -d "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}" ]; then
				mkdir -p "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory"
				mv "$default_path2/$domain_name/masscan/$port/$chunk_file_basename" "$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory"

				# Create a Masscan script for each chunk

				script_file="$default_path2/$domain_name/masscan/$port/${chunk_file_basename}_directory/masscan_${chunk_file_basename}.sh"
				touch "$script_file" 2>/dev/null
				chmod +x "$script_file"

				# Create a Masscan script for each chunk
				cat <<EOF > "$script_file"
#!/bin/bash

orangeColour="\e[0;32m\033[1m"
greenColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
purpleColour="\e[0;34m\033[1m"
grayColour="\e[0;37m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
endColour="\033[0m"

for ip in \$(cat "/${chunk_file}_directory/${chunk_file_basename}"); do
	echo -e "\${turquoiseColour}Scanning\${endColour}\${orangeColour} \$ip\${endColour}\${turquoiseColour} with masscan ...\${endColour}"
	masscan -p"$port" "\$ip" -oG "/$default_path2/$domain_name/masscan/$port/${domain_name}_\${ip}_scan.txt" > /dev/null 2>&1

	if echo  "/$default_path2/$domain_name/masscan/$port/${domain_name}_\${ip}_scan.txt" | grep -q "open"; then
		echo -e "\${orangeColour}Port $port \${endColour}\${orangeColour}found for \${endColour}\${orangeColour}\$ip\${endColour}"
		echo
		for i in \$(seq 1 40); do echo -ne "\${greenColour}-"; done; echo -ne \${endColour}
		echo
	else
		echo -e "\${turquoiseColour}Port $port \${endColour}\${redColour}not found for \${endColour}\${orangeColour}\$ip\${endColour}"
		echo
		for i in \$(seq 1 40); do echo -ne "\${greenColour}-"; done; echo -ne \${endColour}
		echo
		if [ ! -s "/$default_path2/$domain_name/masscan/$port/${domain_name}_\${ip}_scan.txt" ]; then
			rm "/$default_path2/$domain_name/masscan/$port/${domain_name}_\${ip}_scan.txt"
		fi
	fi

done
EOF

				# dimensions of my current display:    1366x768 pixels (361x203 millimeters)
				x_offset=$((running_xterms % columns * (window_width * width_const)))
				cocient=$((x_offset / width_max))
				x_offset=$((x_offset - (cocient * width_max)))
				if ((x_offset < window_width * width_const)); then
					variance="$x_offset"
				fi
				x_offset=$((x_offset - variance))
				y_offset=$((cocient * window_height * height_const))

				if [[ $((max_xterms - xterm_counter)) -ge 1 ]]; then
					# Execute the script in the background
					xterm -geometry ${window_width}x${window_height}+${x_offset}+${y_offset} -e "bash $script_file" &
					xterm_pids+=($!)
					((running_xterms++))
					((xterm_counter++))
					((private_counter++))
				fi

			fi
		done
				# Wait for all background processes (xterm processes) to finish
				wait "${xterm_pids[@]}"
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

nuclei_templates="default"

function nuclei_analyze(){
	start_cronometer

	port=$1
	if [ ! -d "$default_path2/$domain_name/nuclei" ]; then
		mkdir -p "$default_path2/$domain_name/nuclei"
	fi

	mkdir -p "$default_path/templates/$port"
	
	if [ ! -e "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt" ]; then
		# Retrieve IP list of open ports from masscan results
		find  "$default_path2/$domain_name/masscan/$port" -type f | grep -v "$port.txt" | cut -d '/' -f 9 | cut -d '_' -f 2 | sort > "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"
	fi



	columns=$((width_max / (window_width)))
	rows=$((($lines_global + columns - 1) / columns))
	
	private_counter=1

	if [ "$port" = "80" ]; then

		if [ "$global_mode" == "weak" ]; then
			echo -e "\nLoading ${turquoiseColour}Info, Low${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates.txt"
			nuclei -tl -s info,low -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "weak-fast" ]; then
			echo -e "\nLoading ${turquoiseColour}Weak-Fast${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-fast-weak.txt"


		elif [ "$global_mode" == "medium" ]; then
			echo -e "\nLoading ${turquoiseColour}Medium${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates.txt"
			nuclei -tl -s medium -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "strong" ]; then
			echo -e "\nLoading ${turquoiseColour}High, Critical${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates.txt"
			nuclei -tl -s high,critical -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "latest" ]; then
			echo -e "\nLoading ${turquoiseColour}Lastest${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates.txt"
			nuclei -tl -nt -pt http 2>/dev/null > "$nuclei_templates"

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

			echo "#!/bin/bash" 							>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "orangeColour=\"\e[0;32m\033[1m\"" 	>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh" 
			echo "greenColour=\"\033[0m\e[0m\"" 		>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "redColour=\"\e[0;31m\033[1m\"" 		>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "purpleColour=\"\e[0;34m\033[1m\"" 	>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "grayColour=\"\e[0;37m\033[1m\"" 		>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "turquoiseColour=\"\e[0;36m\033[1m\"" 	>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "endColour=\"\033[0m\"" 				>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
			echo "counter=0" 							>> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"


			while read subdomain; do
				while read template; do
					echo -e "\nlet counter+=1" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e 'echo -e "\n${greenColour}Running $counter attempt:${endColour}"' >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "echo -e \"\${turquoiseColour}sudo nuclei -t /home/$username/.local/nuclei-templates/$template -target $ip $subdomain 2>/dev/null | sudo tee /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt\${endColour}\"\n" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					echo -e "sudo nuclei -t /home/$username/.local/nuclei-templates/$template -target $ip $subdomain 2>/dev/null | sudo tee /$default_path2/$domain_name/nuclei/$port/$ip/${template##*/}_${subdomain}_${ip}.txt" >> "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.sh"
					
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
				done < "$nuclei_templates"

		

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
				done < "$nuclei_templates"


			done < "$default_path2/$domain_name/nuclei/$port/$ip/subdomains_${ip}.txt"


		done < "$default_path2/$domain_name/masscan/$port/${domain_name}_${port}.txt"
	
		date=$(date)
		echo "This IP was scanned with the $nuclei_templates at: $date" > "$default_path2/$domain_name/nuclei/$port/$ip/Finished.txt"

	fi

	stop_cronometer
}

start_cronometer() {
    start_time=$(date +%s.%N)
}

stop_cronometer() {
    stop_time=$(date +%s.%N)

    # Calculate the elapsed time in seconds with nanosecond precision
    elapsed_time=$(echo "$stop_time - $start_time" | bc)

    # Format the elapsed time for display
    formatted_time=$(printf "%.2f" "$elapsed_time")

    # Print the elapsed time
    echo "Elapsed time: ${formatted_time} seconds"
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

width_const=6
height_const=12

width_max=1366
height_max=768

window_width=50
window_height=80

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

