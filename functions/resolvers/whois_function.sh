#!/bin/bash

function whois_function(){
	if [ ! -d "$default_path2/$domain_name/whois" ]; then
		mkdir -p "$default_path2/$domain_name/whois"
	fi


	columns=$((width_max / (window_width)))
	rows=$((($lines_global + columns - 1) / columns))
	
	private_counter=1


	echo -e "Determining whois the IP's related to ${orangeColour} $domain_name${endColour} from this file:"
	echo -e "${turquoiseColour}/$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt ${endColour}"
	input_file="$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt"
	temp_file="$(mktemp)"

	# Use grep to remove "timed out" lines and save the result to the temporary file
	grep -v "timed out" "$input_file" > "$temp_file"

	# Replace the original file with the temporary file
	mv "$temp_file" "$input_file"
	echo

	# Divide the IPs into smaller files
	lines_global=$(wc -l < "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt")
	split -d -l $((lines_global / max_xterms)) "$default_path2/$domain_name/${domain_name}_IPs_clean_sorted.txt" "$default_path2/$domain_name/whois/ip_chunk_"

	echo -e "${grayColour}Total IP's:${endColour}		$lines_global"
	echo -e "${grayColour}Parallel Windows:${endColour}	$max_xterms"
	echo -e "${grayColour}IP's per Window:${endColour} 	$((lines_global / max_xterms))"
	echo

	# Loop through the IP chunks and create scripts for each
	for chunk_file in "$default_path2/$domain_name/whois/ip_chunk_"*; do
		chunk_file_basename=$(basename "$chunk_file")

		if [ ! -d "$default_path2/$domain_name/whois/${chunk_file_basename}" ]; then
			mkdir -p "$default_path2/$domain_name/whois/${chunk_file_basename}_directory"
			mv "$default_path2/$domain_name/whois/$chunk_file_basename" "$default_path2/$domain_name/whois/${chunk_file_basename}_directory"

			# Create a Whois script for each chunk

			script_file="$default_path2/$domain_name/whois/${chunk_file_basename}_directory/whois_${chunk_file_basename}.sh"
			touch "$script_file" 2>/dev/null
			chmod +x "$script_file"

			# Create a Whois script for each chunk
			cat <<EOF > "$script_file"
#!/bin/bash

orangeColour="\e[0;32m\033[1m"
greenColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
purpleColour="\e[0;34m\033[1m"
grayColour="\e[0;37m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
endColour="\033[0m"

counter=1


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

file_path="/$default_path2/$domain_name/whois/whois_${domain_name}_\${ip}_scan.txt"
echo -e "\${orangeColour}\$counter	->\${endColour}\${turquoiseColour} Whois\${endColour}\${orangeColour} \$ip\${endColour}\${turquoiseColour} ...\${endColour}"

# Wait for internet connectivity
while ! check_internet; do
  echo "Internet is not reachable. Waiting..."
  sleep 5  # Adjust the sleep interval as needed
done

global_variable=0
if [ -e "\$file_path" ]; then
	echo -e "\${greenColour}Whois file already exists!\${endColour}"
	global_variable=1
fi

if [ "\$global_variable" == "0" ]; then
	whois "\$ip" | tee "\$file_path" > /dev/null 2>&1
	sleep 2
fi

# Remove lines starting with "#" using sed
sed -i '/^#/d' "\$file_path" 2>/dev/null

# Check if the file is empty and delete it
if [ ! -s "\$file_path" ]; then
    rm "\$file_path" 2>/dev/null
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
}
