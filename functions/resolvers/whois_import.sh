#!/bin/bash

function whois_import() {
    if [ ! -d "$default_path/database/" ]; then
        mkdir -p "$default_path/database/"
    fi
    if [ ! -d "$default_path/database/scripts" ]; then
        mkdir -p "$default_path/database/scripts"
    fi

    # Create the database if it doesn't exist
    database_path="$default_path/database/whois.db"
    if [ ! -e "$database_path" ]; then
        sqlite3 "$database_path" ""
    fi

    database_script="$default_path/database/scripts/whois.sql"

    # Define the SQL statements for creating the table
    cat > "$database_script" <<EOF
CREATE TABLE IF NOT EXISTS whois_data (
    id INTEGER PRIMARY KEY,
    ip_address VARCHAR(15),
    domain_name VARCHAR(100),
    inetnum VARCHAR(50),
    status VARCHAR(50),
    "aut-num" VARCHAR(50),
    owner VARCHAR(255),
    responsible VARCHAR(255),
    address VARCHAR(1000),
    phone VARCHAR(20),
    "owner-c" VARCHAR(50),
    "tech-c" VARCHAR(50),
    "abuse-c" VARCHAR(50),
    inetrev VARCHAR(50),
    nserver VARCHAR(255),
    nsstat VARCHAR(20),
    nslastaa VARCHAR(20),
    created VARCHAR(20),
    changed VARCHAR(20),
    "nic-hdl" VARCHAR(50),
    person VARCHAR(255),
    "e-mail" VARCHAR(255),
    "NetRange" VARCHAR(255),
    "CIDR" VARCHAR(255),
    "NetName" VARCHAR(255),
    "NetHandle" VARCHAR(255),
    "Parent" VARCHAR(255),
    "NetType" VARCHAR(255),
    "OriginAS" VARCHAR(255),
    "Organization" VARCHAR(255),
    "RegDate" VARCHAR(255),
    "Updated" VARCHAR(255),
    "Ref" VARCHAR(255),
    "OrgName" VARCHAR(255),
    "OrgId" VARCHAR(255),
    "OrgAddress" VARCHAR(255),
    "City" VARCHAR(255),
    "StateProv" VARCHAR(255),
    "PostalCode" VARCHAR(255),
    "Country" VARCHAR(255),
    "OrgRegDate" VARCHAR(255),
    "OrgUpdated" VARCHAR(255),
    "OrgRef" VARCHAR(255),
    "OrgTechHandle" VARCHAR(255),
    "OrgTechName" VARCHAR(255),
    "OrgTechPhone" VARCHAR(255),
    "OrgTechEmail" VARCHAR(255),
    "OrgTechRef" VARCHAR(255),
    "OrgAbuseHandle" VARCHAR(255),
    "OrgAbuseName" VARCHAR(255),
    "OrgAbusePhone" VARCHAR(255),
    "OrgAbuseEmail" VARCHAR(255),
    "OrgAbuseRef" VARCHAR(255)
);
EOF

    # Display a message indicating that the init SQL script has been generated
    sqlite3 -bail "$database_path" < "$database_script"

    # Values to extract
    strings=("inetnum"
        "status"
        "aut-num"
        "owner"
        "responsible"
        "address"
        "phone"
        "owner-c"
        "tech-c"
        "abuse-c"
        "inetrev"
        "nserver"
        "nsstat"
        "nslastaa"
        "created"
        "changed"
        "nic-hdl"
        "person"
        "e-mail"
        "NetRange"
        "CIDR"
        "NetName"
        "NetHandle"
        "Parent"
        "NetType"
        "OriginAS"
        "Organization"
        "RegDate"
        "Updated"
        "Ref"
        "OrgName"
        "OrgId"
        "OrgAddress"
        "City"
        "StateProv"
        "PostalCode"
        "Country"
        "OrgRegDate"
        "OrgUpdated"
        "OrgRef"
        "OrgTechHandle"
        "OrgTechName"
        "OrgTechPhone"
        "OrgTechEmail"
        "OrgTechRef"
        "OrgAbuseHandle"
        "OrgAbuseName"
        "OrgAbusePhone"
        "OrgAbuseEmail"
        "OrgAbuseRef"
    )

	declare -A values
	echo
	echo -e "All the next files will be dumped into the ${turquoiseColour}/$database_path${endColour}"
	echo

	# Loop through the associative array and insert values into the table
	for file in "$default_path2/$domain_name/whois"/whois*; do
		echo "/$file"
		ip=$(echo "$file" | cut -d "_" -f 4)
		current_domain=$(echo "$file" | cut -d "_" -f 3)
		if [ -n "$file" ]; then
			# Check if the file exists and is not empty before inserting
			if [ -s "$file" ]; then
				# Define the SQL INSERT INTO statement
				insert_sql="INSERT INTO whois_data (\"ip_address\", \"domain_name\", "
				values_sql="VALUES ('$ip', '$current_domain', "

				for string in "${strings[@]}"; do
					# Remove colons from string to make it a valid column name
					column_name="\"${string}\""


					# Add the column name to the INSERT INTO statement
					insert_sql="$insert_sql$column_name, "

					# Add the value to the VALUES statement
					value=$(grep -oP "^$string\s*\K.*" "$file" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | head -n 1)
					
					# Escape single quotes in the value to prevent SQL injection
					value="${value//\'/''}"

					values_sql="$values_sql'$value', "
				done

				# Remove the trailing comma and space from both statements
				insert_sql="${insert_sql%, }"
				values_sql="${values_sql%, }"

				# Complete the SQL statements
				insert_sql="$insert_sql) $values_sql);"

				# Insert the values into the database
				sqlite3 "$database_path" "$insert_sql"
				#echo "$insert_sql"
				#sleep 30
			else
				echo "The $file is empty"
			fi
		fi
	done

}
