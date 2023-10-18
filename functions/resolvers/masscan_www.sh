#!/bin/bash

function masscan_www() {
	start_cronometer
	ip_range=$1
	
	if [ ! -d "$default_path2/www/masscan" ]; then
		mkdir -p "$default_path2/www/masscan"
	fi
	if [ ! -d "$default_path2/www/masscan/$ip" ]; then
		mkdir -p "$default_path2/www/masscan/$ip"
	fi

	columns=$((width_max / (window_width)))
	rows=$((($lines_global + columns - 1) / columns))

	# Divide the IPs into smaller files
	list_IP_file="$default_path2/www/$(echo "$ip_range" | tr / _)_list_IP.txt"
	rm "$list_IP_file" 2>/dev/null
	touch "$list_IP_file" 2>/dev/null

	private_counter=1

	if [ ! -s "$list_IP_file" ]; then
		# Generate the list of all the IP's in the range and save it
		for ip in $(nmap -n -sL "$ip_range" | awk '/Nmap scan report/{print $5}'); do
			echo "$ip" >> "$list_IP_file"
		done
	fi

	lines_global=$(wc -l < "$list_IP_file")
	split -d -l $((lines_global / max_xterms)) "$list_IP_file" "$default_path2/www/masscan/ip_chunk_"

	echo
	echo -e "Scanning the list of IP's in ${orangeColour} $max_xterms${endColour} windows, from this file:"
	echo -e "${turquoiseColour}$list_IP_file ${endColour}"
	echo -e "${grayColour}Total IP's:${endColour}		$lines_global"
	echo -e "${grayColour}Port:	${endColour}		$ports"
	echo -e "${grayColour}Parallel Windows:${endColour}	$max_xterms"
	echo -e "${grayColour}IP's per Window:${endColour} 	$((lines_global / max_xterms))"
	echo




	# Loop through the IP chunks and create scripts for each
	for chunk_file in "$default_path2/www/masscan/ip_chunk_"*; do
		chunk_file_basename=$(basename "$chunk_file")

		if [ ! -d "$default_path2/www/masscan/${chunk_file_basename}" ]; then
			mkdir -p "$default_path2/www/masscan/${chunk_file_basename}_directory"
			mv "$default_path2/www/masscan/$chunk_file_basename" "$default_path2/www/masscan/${chunk_file_basename}_directory"

			# Create a Masscan script for each chunk

			script_file="$default_path2/www/masscan/${chunk_file_basename}_directory/masscan_${chunk_file_basename}.sh"
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

# Function to check internet connectivity
check_internet() {
  actual_IP=\$(curl -s ifconfig.me)
  if [ -n \"\$actual_IP\" ]; then
	return 0	
  else
	return 1
  fi
}


for ip in \$(cat "/${chunk_file}_directory/${chunk_file_basename}"); do

	echo
	echo -e "\${turquoiseColour}Scanning\${endColour}\${orangeColour} \$ip\${endColour}\${turquoiseColour} with masscan in port \$ports\${endColour}" 

	# Wait for internet connectivity
	while ! check_internet; do
		echo "Internet is not reachable. Waiting..."
		sleep 5  # Adjust the sleep interval as needed
	done

	global_variable=0
	if [ -d "$default_path2/www/masscan/\${ip}" ]; then
		echo -e "\${greenColour}Masscan result already realized!\${endColour}"
		global_variable=1
	else
		if [ ! -d "$default_path2/www/masscan/\${ip}" ]; then
			mkdir -p "$default_path2/www/masscan/\${ip}"
		fi

		echo "sudo masscan \$ip --ports $ports -oG $default_path2/www/masscan/\${ip}/\${ip}_scan_${ports}.txt" 
		sudo masscan \$ip --ports $ports -oG "$default_path2/www/masscan/\${ip}/\${ip}_scan_${ports}.txt" 

		# Check if the file is empty and delete it
		if [ ! -s "$default_path2/www/masscan/\${ip}/\${ip}_scan_${ports}.txt" ]; then
			current_date=\$(date)
			echo "Finished at:	\$current_date" > "$default_path2/www/masscan/\${ip}/\${ip}_log_${ports}.txt"
			rm "$default_path2/www/masscan/\${ip}/\${ip}_scan_${ports}.txt" 2>/dev/null
		fi
	fi
	
	let counter+=1
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

	stop_cronometer

	current_date=$(date)
	ip_range_fixed=$(echo "$ip_range" | tr / _)

	final_log_file="$default_path2/www/${ip_range_fixed}_log_${ports}.txt"
	rm "$final_log_file" 2>/dev/null
	echo "Space_Scan done at:	${orangeColour}$current_date ${endColour}"					>> "$final_log_file"
	echo																					>> "$final_log_file"	
	echo "List of scanned IP's:"															>> "$final_log_file"
	echo -e "${turquoiseColour}$list_IP_file ${endColour}"									>> "$final_log_file"
	echo																					>> "$final_log_file"	
	echo -e "${orangeColour}Total IP's:${endColour}			$lines_global"					>> "$final_log_file"
	echo -e "${orangeColour}Port:	${endColour}		$ports"								>> "$final_log_file"
	echo -e "${orangeColour}Parallel Windows:${endColour}	$max_xterms"					>> "$final_log_file"
	echo -e "${orangeColour}IP's per Window:${endColour} 	$((lines_global / max_xterms))"	>> "$final_log_file"
	echo -e "${orangeColour}Final Time:${endColour}		$final_time"						>> "$final_log_file"
	echo
}
