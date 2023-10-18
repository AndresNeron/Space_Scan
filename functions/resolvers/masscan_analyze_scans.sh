#!/bin/bash

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
