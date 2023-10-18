#!/bin/bash

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
