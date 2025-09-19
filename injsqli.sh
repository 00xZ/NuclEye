domain=$1
while read url; do
  while read payload; do
    echo "$url" | qsreplace "$payload"
  done < payloads/sqli_payloads.txt
done < output/sqli_xxx_tmp.txt > output/urls_injected_tmp.txt
