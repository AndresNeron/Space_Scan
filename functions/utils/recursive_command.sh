#!/bin/bash

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
