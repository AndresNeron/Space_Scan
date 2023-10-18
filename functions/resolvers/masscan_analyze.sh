#!/bin/bash

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
