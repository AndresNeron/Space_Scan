#!/bin/bash

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
