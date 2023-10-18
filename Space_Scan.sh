#!/bin/bash


function helpPanel(){
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n${purpleColour}This program automates scanning tools usage for Bug Hunting${endColour}" 
	echo -e "${purpleColour}against domain names.${endColour}" 
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n${turquoiseColour} [!] Usage:${endColour} ${orangeColour}sudo ./Space_Scan.sh -d [domain]${endColour}"
	for i in $(seq 1 65); do echo -ne "${greenColour}-"; done; echo -ne ${endColour}
	echo -e "\n\t${orangeColour}-d\t--domain\t\t${endColour}${turquoiseColour} Receives main domain${endColour}"
	echo -e "\t${orangeColour}-l\t--list\t\t\t${endColour}${turquoiseColour} Receives list of main domains${endColour}"
	echo -e "\t${orangeColour}-s\t--subfinder\t\t${endColour}${turquoiseColour} Run subfinder${endColour}"
	echo -e "\t${orangeColour}-o\t--dns-resolution\t${endColour}${turquoiseColour} Run dns resolution${endColour}"
	echo -e "\t${orangeColour}-e\t--whois\t\t\t${endColour}${turquoiseColour} Run whois to each IP associated with the domain${endColour}"
	echo -e "\t${orangeColour}-f\t--whois-import\t\t${endColour}${turquoiseColour} Dump the whois previous results into the database${endColour}"
	echo -e "\t${orangeColour}-g\t--geolocation\t\t${endColour}${turquoiseColour} Get the exact location of the servers${endColour}"
	echo -e "\t${orangeColour}-m\t--masscan-analyze\t${endColour}${turquoiseColour} Analyze clean IP's with masscan${endColour}"
	echo -e "\t${orangeColour}-p\t--ports\t\t\t${endColour}${turquoiseColour} Select ports to scan${endColour}"
	echo -e "\t${orangeColour}-j\t--masscan-www\t\t${endColour}${turquoiseColour} Run masscan against a list of public IP's, not necessarily related to the same domain${endColour}"
	echo -e "\t${orangeColour}-n\t--nmap-analyze\t\t${endColour}${turquoiseColour} Analyze clean IP's with nmap${endColour}"
	echo -e "\t${orangeColour}-i\t--nuclei-analyze\t${endColour}${turquoiseColour} Analyze clean IP's with nuclei${endColour}"
	echo -e "\t${orangeColour}-a\t--analyze-masscan\t${endColour}${turquoiseColour} Analyze masscan results${endColour}"
	echo -e "\t${orangeColour}-r\t--recursive\t\t${endColour}${turquoiseColour} Execute recursive commands${endColour}"
	echo -e "\t${orangeColour}-t\t--nuclei-mode\t\t${endColour}${turquoiseColour} Setup nuclei mode options: [weak, weak-fast, medium, strong, latest]${endColour}"
	echo -e "\t${grayColour}\t\tweak\t\t${endColour}${turquoiseColour} Use the weak severity templates from nuclei ${endColour}"
	echo -e "\t${grayColour}\t\tweak-fast\t${endColour}${turquoiseColour} Use the most common weak severity templates from nuclei ${endColour}"
	echo -e "\t${grayColour}\t\ttags-slow\t${endColour}${turquoiseColour} Use wappalyzer technology detection templates to tags mapping ${endColour}"
	echo -e "\t${grayColour}\t\tmedium\t\t${endColour}${turquoiseColour} Use the medium severity templates from nuclei ${endColour}"
	echo -e "\t${grayColour}\t\tstrong\t\t${endColour}${turquoiseColour} Use the high and critical severity templates from nuclei ${endColour}"
	echo -e "\t${grayColour}\t\tlatest\t\t${endColour}${turquoiseColour} Use the latest templates from nuclei ${endColour}"
	echo -e "\t${orangeColour}-w\t--windows\t\t${endColour}${turquoiseColour} Setup how many windows will be opened simultaneously${endColour}${turquoiseColour}  ${endColour}"
	echo -e "\t${orangeColour}-h\t--help\t\t\t${endColour}${turquoiseColour} Show this help message${endColour}${turquoiseColour}  ${endColour}"
	echo -e "\n\t${orangeColour}Examples:\t${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -s -o${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -m${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -a${endColour} all"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -e${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -f${endColour}"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s -o\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-s -o -m all\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -n 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -r${endColour} ${greenColour}\"-m 80 -i 80\"${endColour}${orangeColour} -l${endColour} domainlist.txt"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -w${endColour} 4${orangeColour} -m${endColour} 80"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -d${endColour} ${greenColour}example.com${endColour}${orangeColour} -w${endColour} 4${orangeColour} -t${endColour} weak${orangeColour} -i${endColour} 80"
	echo -e "\t${turquoiseColour} sudo ./Space_Scan.sh${endColour}${orangeColour} -p${endColour} 21 ${orangeColour}-w ${endColour}10${orangeColour} -j${endColour} 10.0.0.0/24${orangeColour} -t${endColour} weak${orangeColour} -i${endColour} 80"

	exit 1
}


# Get the username of the normal user or the sudo user if empty
if [ -n "$SUDO_USER" ]; then
    username="$SUDO_USER"
else
    username="$USER"
fi

# Check if the username is empty (indicating that sudo was not used)
if [ -z "$username" ]; then
    echo "Unable to determine the username. Please run this script with sudo."
    exit 1
fi

# This is the default path where the images will be saved.
default_path="home/$username/Bash/Space_Scan"
cd /

if [ ! -d "$default_path" ]; then
	mkdir -p $default_path
fi

default_path2="$default_path/targets"
if [ ! -d "$default_path2" ]; then
	mkdir -p $default_path2
fi

# Include function files
for file in "$default_path/functions/"*/*; do
	if [ -f "$file" ]; then
		source "$file"
	fi
done


# Global variables
recursive_string_global="h"
recursive_counter=0
lines_global=3
x_offset=0
y_offset=0
global_mode=0
max_xterms=$((4+1))
running_xterms=0
xterm_counter=0

width_const=6
height_const=12

width_max=1366
height_max=768

window_width=50
window_height=80

ip_range='0.0.0.0/0'
ports=80
final_time=0



#--------------------------
# Main Function
xterm_pids=()
counter=0

ARGS=$(getopt -o d:w:l:soefgt:m:p:j:n:i:a:r:h --long domain:,windows:,list:,subfinder,dns-resolution,whois,whois-import,geolocation,nuclei-mode:,masscan-analyze:,ports:,masscan-www:,nmap-analyze,nuclei-analyze,analyze-masscan,recursive:,help -n "$0" -- "$@")
eval set -- "$ARGS"

while true; do
    case "$1" in
        -d|--domain)
            domain_name="$2"
            counter=$((counter + 1))
            shift 2
            ;;
        -w|--windows)
            max_xterms="$2"
			windows "$max_xterms" 
            counter=$((counter + 1))
            shift 2
            ;;
        -l|--list)
            domain_list="$2"
            iterate_domains "$domain_list"
            counter=$((counter + 1))
            shift 2
            ;;
        -s|--subfinder)
            subfinder_fetch 
            counter=$((counter + 1))
            shift 2
            ;;
        -o|--dns-resolution)
            dns_resolution
            counter=$((counter + 1))
            shift
            ;;
        -e|--whois)
            whois_function
            counter=$((counter + 1))
            shift
            ;;
        -f|--whois-import)
            whois_import 
            counter=$((counter + 1))
            shift
            ;;
        -g|--geolocation)
            geolocation
            counter=$((counter + 1))
            shift
            ;;
        -t|--nuclei-mode)
            global_mode="$2"
			mode "$global_mode" 
            counter=$((counter + 1))
            shift 2
            ;;
        -m|--masscan-analyze)
            port="$2"
            masscan_analyze "$port"
            counter=$((counter + 1))
            shift 2
            ;;
        -p|--ports)
            ports="$2"
            counter=$((counter + 1))
            shift 2
            ;;
        -j|--masscan-www)
            ip_range="$2"
            masscan_www "$ip_range"
            counter=$((counter + 1))
            shift 2
            ;;
        -n|--nmap-analyze)
			port="$2"
			shift
            nmap_analyze "$port"
            counter=$((counter + 1))
            shift
            ;;
        -i|--nuclei-analyze)
			port=$2
			shift
            nuclei_analyze $port
            counter=$((counter + 1))
            shift
            ;;
        -a|--analyze-masscan)
            port="$2"
            masscan_analyze_scans "$port"
            counter=$((counter + 1))
            shift 2
            ;;
		-r|--recursive)
			recursive_string_global="$2"
			shift
			echo "$recursive_string"
			recursive_command "$recursive_string"
            counter=$((counter + 1))
			shift 
            ;;
        -h|--help)
            helpPanel
            ;;
        --)
            shift
            break
            ;;
        *)
            helpPanel
            echo -e "\n${redColour}[!] Invalid option. Exiting...\n${endColour}"
            exit 1
            ;;
    esac
done

# Restore cursor and show help if no options were provided
tput cnorm
if [ "$counter" -eq 0 ]; then
    helpPanel
fi
