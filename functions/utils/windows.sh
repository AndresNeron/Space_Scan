#!/bin/bash

function windows() {
	max_xterms=$1
	if [ "$max_xterms" -gt 30 ]; then
		echo "The total number of windows cannot be greater than 8"
	fi
}
