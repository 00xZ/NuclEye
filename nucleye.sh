#!/bin/bash
#This was intended to be the start of a customer shodan.io but i found this use case for it and its been good for research.
## colors
BOLD="\e[1m"
CYAN='\033[0;36m'
RED='\033[0;31m'
black='\033[0;30m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
NC='\033[0m' # No Color
scan_type=$2

main_loop() {
    #trap ":" INT
    #echo "$scan_type debug"
    while true
    do
            echo -e "\n$RED${BOLD} [!]$green Scanning The Web $NC- $magenta Loop ${NC} : $CYAN${BOLD} $Counter_dub $RED${BOLD}[!]$NC$CYAN"
            python3 emap.py 443 40 ips.txt 5 #use my port scanner or use zmap but zmap tends to make even my 300mbps wifi stutter
            #zmap -N 15 -p 443 -o ips.txt -B 100M -i wlan0
            echo -e "$RED${BOLD} 10 Sec Sleep : needed for gdn "
            sec=10
            while [ $sec -ge 0 ]; do
                echo -ne "   Time: $sec\033[0K\r"
                let "sec=sec-1"
                sleep 1
            done
            echo -e "$magenta${BOLD} [x] Pulling domains [x]${NC}$green${BOLD}"
            cat ips.txt | gdn |awk '{print $2}' | tee output/targets.txt
            echo -e "$green Targets:"
            cat output/targets.txt
            #cat output/targets.txt | sort -u | uniq | tee output/targets.txt
            echo -e "$yellow[+] Grabbing info[+] ${NC}$magenta"
            cat output/targets.txt | anew output/raw_db.txt
            cat output/targets.txt | httpx -sc -title -fr | anew output/database.txt
            #cat ips.txt | httpx -sc -title | anew output/ip_database.txt
            echo -e "$magenta$ [+] Parsing [+] "
            cat output/database.txt | grep "200" | awk '{print $1}' | anew all.txt
            rm ips.txt
            cat output/targets.txt | subfinder -silent | httpx -silent | tee output/subs.txt
            cat output/subs.txt | httpx -sc -fr -title | anew output/httpx_subs_db.txt
            cat output/subs.txt | anew output/sub-database.txt
            cat output/subs.txt | katana -silent | anew output/spider_db_tmp.txt
            cat output/spider_db_tmp.txt | anew output/spider_db.txt
            cat output/spider_db_tmp.txt | grep '\.php' | grep '?' | grep '=' |  qsreplace xxx | anew output/sqli_xxx_tmp.txt
            ./injsqli.sh 
            ./zql.sh --debug
            #./no-sql-eye.sh $domain --debug
            rm output/sqli_xxx_tmp.txt
            rm output/urls_injected_tmp.txt
            rm output/spider_db_tmp.txt
            echo -e "\n$RED${BOLD} [!]$green Finding Vulnerable Services $NC- $magenta CVE $RED${BOLD}[!]$NC"
            nuclei -l output/targets.txt -tags cve -s critical,high,medium,low | anew vuln.db
            #echo -e "\n$RED${BOLD} [!]$green Technologies Detection $NC- $magenta Nuclei $RED${BOLD}[!]$NC"
            #cat output/subs.txt | nuclei -t technologies/tech-detect.yaml | anew technologies.txt
            Counter_dub=$[$Counter_dub +1]
            #./update_site.sh
            if [ "$1" == "-xss" ]; then
                xss_scan
            else
                echo -e "${RED}Looping Scan ${NC}"
                main_loop
                #exit
            fi
            #(trap - INT; cat spider/live_xss.txt | dalfox pipe | anew Vuln_xss.txt)
            #rm target.txt
            #killall gdn # more so debugging stuff keeping it just incase any problems come up with gdn not pulling after a few scans
            echo " [!] LOOP [!] "
    done
}


help() {
    echo -e "$CYAN${BOLD}Usage:${NC}"
    echo -e "${BOLD}    -help            Shows the help menu${NC}"
    echo -e "$magenta${BOLD}    -scan           Loop[emap/find webservers|katana/spider|gf/parse${NC}"
    #echo -e "$RED${BOLD}    -xss           Scan the database for XSS(dalfox)${NC}"
    echo -e "$magenta${BOLD} ____________________________________________________${NC}"
    exit 0
}
if [ "$1" == "-scan" ]; then
    main_loop
elif [ "$1" == "-xss" ]; then
    xss_scan
else
    echo -e "${RED}Unknown option: $1 ${NC}"
    help
fi
