#!/bin/bash

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
			nuclei_templates="$default_path/templates/$port/nuclei-templates-info-low.txt"
			nuclei -tl -s info,low -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "weak-fast" ]; then
			echo -e "\nLoading ${turquoiseColour}Weak-Fast${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-weak-fast.txt"


		elif [ "$global_mode" == "tags-slow" ]; then
			echo -e "\nLoading ${turquoiseColour}Tags${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-tags-slow.txt"
			nuclei -tl -as -pt http 2>/dev/null > "$nuclei_templates"


		elif [ "$global_mode" == "medium" ]; then
			echo -e "\nLoading ${turquoiseColour}Medium${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-medium.txt"
			nuclei -tl -s medium -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "strong" ]; then
			echo -e "\nLoading ${turquoiseColour}High, Critical${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-high-critical.txt"
			nuclei -tl -s high,critical -pt http 2>/dev/null > "$nuclei_templates"

		elif [ "$global_mode" == "latest" ]; then
			echo -e "\nLoading ${turquoiseColour}Lastest${endColour} templates to use it."
			nuclei_templates="$default_path/templates/$port/nuclei-templates-latest.txt"
			nuclei -tl -nt -pt http 2>/dev/null > "$nuclei_templates"

		else
			echo "Select a valid option for mode for nuclei."
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

