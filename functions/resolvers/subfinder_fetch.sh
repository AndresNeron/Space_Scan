#!/bin/bash

function subfinder_fetch() {
	if [ ! -d "$default_path2/$domain_name" ]; then
		mkdir -p "$default_path2/$domain_name"
		echo -e "Successful directory creation at $default_path2/$domain_name"
	fi
	subfinder -d "$domain_name" | tee "$default_path2/$domain_name/$domain_name.txt"
	echo
	echo -e "${turquoiseColour}Subdomains fetched -> /$default_path2/$domain_name/$domain_name.txt${endColour}"
}
