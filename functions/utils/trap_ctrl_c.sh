#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c() {
	echo -e "\n${redColour}Received Ctrl+C, cleaning up...${endColour}"

    #kill "${xterm_pids[@]}" 2>/dev/null

	# Kill all xterm processes and their children
    for pid in "${xterm_pids[@]}"; do
        pkill -P "$pid"
    done

    echo -e "\n${redColour}[!] Exiting...\n${endColour}"
    tput cnorm; 
    exit 1
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c() {
	echo -e "\n${redColour}Received Ctrl+C, cleaning up...${endColour}"

    #kill "${xterm_pids[@]}" 2>/dev/null

	# Kill all xterm processes and their children
    for pid in "${xterm_pids[@]}"; do
	        pkill -P "$pid"
		    done

		    echo -e "\n${redColour}[!] Exiting...\n${endColour}"
		    tput cnorm; 
		    exit 1
		}
}
