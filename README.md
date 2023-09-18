# Space Scan

Space Scan is a Bash program designed for inspecting domain names and automating the use of various 
cybersecurity scanning tools. This script simplifies the process of scanning domains for security 
analysis, making it a valuable asset for cybersecurity professionals and enthusiasts.


## Prerequisites
Prior to using this script, ensure you have the following tools installed:
- subfinder
- masscan
- nmap
- nuclei
- bash

## Usage 
Execute the script with administrative privileges using `sudo`:

```bash
sudo ./Space_Scan.sh [options]
```

## Options
Space Scan provides several options to tailor your scanning process:

-    -d, --domain: Specify the main domain to scan.
-    -l, --list: Provide a list of main domains to scan.
-    -s, --subfinder: Run subfinder to discover subdomains.
-    -o, --dns-resolution: Perform DNS resolution on discovered subdomains.
-    -m, --masscan-analyze: Analyze clean IP addresses with Masscan.
-    -n, --nmap-analyze: Analyze clean IP addresses with Nmap.
-    -i, --nuclei-analyze: Analyze clean IP addresses with Nuclei.
-    -a, --analyze-masscan: Analyze Masscan results.
-    -r, --recursive: Execute recursive commands within double quotes (e.g., "-s 1 -o").
-    -t, --time: Set up a time lapse for the scanning process.
-    -t, --mode: Setup nuclei mode options: [weak, medium, strong]
-    -w, --windows: Setup how many windows will be opened simultaneously
-    -h, --help: Display this help message.


## Examples
Here are some usage examples for Space_Scan:

- Resolve the subdomains of a main domain and do DNS resolution of each subdomain.
```bash
sudo ./Space_Scan.sh -d example.com -s 1 -o
```

- Scan all the open ports of a few subdomains with masscan.
```bash
sudo ./Space_Scan.sh -d example.com -m all
```

- Print the list of all the open ports retrieved in the command above.
```bash
sudo ./Space_Scan.sh -d example.com -a all
```

- Retrieve the subdomains and resolve DNS resolution of a list of main domains.
```bash
sudo ./Space_Scan.sh -r "-s 1 -o" -l domainlist.txt
```

- Scan all the open ports of a list of main domains using masscan.
```bash
sudo ./Space_Scan.sh -r "-m all" -l domainlist.txt
```

- Run subfinder, dns resolution and masscan in a single threat.
```bash
sudo ./Space_Scan.sh -r "-s 1 -o -m all" -l domainlist.txt
```

- Run masscan and nmap in a certain port in that order.
```bash
sudo ./Space_Scan.sh -r "-m 80 -n 80" -l domainlist.txt
```

- Run masscan and nuclei templates in a certain port in that order.
```bash
sudo ./Space_Scan.sh -r "-m 80 -i 80" -l domainlist.txt
```
- Analyze all the IP's with weak nuclei templates (speed of four IP's at the same time).
```bash
	sudo ./Space_Scan.sh -d example.com -w 4 -t weak -i 80"
```

## Note

Some commands are needed before executing other commands. Per example, is necessary to run subfinder, dns resolution, 
masscan, nmap and nuclei, in that order.

## License

This project is licensed under the [MIT License](LICENSE).

