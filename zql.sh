#!/bin/bash

debug=false



echo -e "\n [✔] Scanning SQL Injection (Error Method) "
url_file="output/urls_injected_tmp.txt"
output_file="output/sqli_vuln.txt"

# Prepare output file
mkdir -p "output/$domain"
> "$output_file"

# SQL error keywords to look for
errors=(
  "You have an error in your SQL syntax"
  "Warning: mysql"
  "Unclosed quotation mark"
  "syntax error"
  "mysql_fetch"
  "MySQL server version"
  "SQLSTATE"
  "PDOException"
  "ORA-01756"
  "mysql_"
  "MariaDB"
)

# Main loop
while IFS= read -r url || [[ -n "$url" ]]; do
  clean_url=$(echo "$url" | tr -d '\000')
  [[ -z "$clean_url" ]] && continue

  $debug && echo "[DEBUG] Testing: $clean_url"

  response=$(curl -s "$clean_url")

  for err in "${errors[@]}"; do
    if echo "$response" | grep -iq "$err"; then
      echo "[Potential SQLi] $clean_url"
      echo "$clean_url" >> "$output_file"
      break
    fi
  done

done < "$url_file"
