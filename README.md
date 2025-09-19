# NuclEye

**NuclEye** is a lightweight Bash orchestration script that automates web reconnaissance and vulnerability scanning workflows by chaining common OSS tools (port scanning → domain extraction → probing → crawling → Nuclei scanning).  
**Intended for authorized research and lab use only.**

---

## ⚠️ Important — Legal Notice
**Do not** run this tool against systems you do not own or do not have explicit, written permission to test. Unauthorized scanning or probing may be illegal. Use only in lab environments or with proper authorization and follow responsible disclosure practices.

---

## Description
NuclEye continuously discovers hosts, extracts domains, enumerates subdomains, probes HTTP endpoints, crawls sites, prepares simple injection payloads, and runs Nuclei templates to find vulnerabilities. Results are saved to the `output/` folder as plain text for review.

---

## Requirements
Make sure these tools and utilities are installed and in your `PATH`:

- `bash`, `python3`
- `httpx`, `subfinder`, `katana`, `nuclei`
- `qsreplace`, `anew`
- `awk`, `grep`, `cat`, `tee` (standard Unix utils)  
Also include any helper scripts referenced in the repo (`emap.py`, `injsqli.sh`, `zql.sh`).

---

## Install
```bash
# clone
git clone https://github.com/00xZ/NuclEye.git
cd NuclEye

# make scripts executable
chmod +x NuclEye.sh emap.py injsqli.sh zql.sh

# ensure required tools are installed (example using Go for some tools)
# go install github.com/projectdiscovery/httpx/cmd/httpx@latest
# go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# ...install nuclei, katana, qsreplace, anew per their docs


## Outputs / How results are stored

NuclEye writes data to the repo root and the `output/` folder. Below is a quick map of the most important files and what they contain:

- `output/targets.txt` — Domains extracted from discovered IPs (one domain per line).  
- `output/database.txt` — `httpx` probe results for `targets.txt` (status codes, titles, etc.).  
- `output/subs.txt` — Discovered subdomains (one per line).  
- `output/httpx_subs_db.txt` — `httpx` hits for `subs.txt`.  
- `output/spider_db.txt` — URLs discovered by the crawler (`katana`).  
- `output/raw_db.txt` — Raw/append-only list of targets (preserves history).  
- `all.txt` — Consolidated list of live endpoints (derived from `database.txt` filtered for 200 responses).  
- `vuln.db` — Nuclei results (CVE and other templates) appended here.  
- Temporary files used during runs: `ips.txt`, `output/spider_db_tmp.txt`, `output/sqli_xxx_tmp.txt` — these are removed by the script when finished.

### Quick commands to inspect & tidy results
```bash
# view unique targets
sort -u output/targets.txt | sed -n '1,50p'

# view recent vulnerabilities (last 50 lines)
tail -n 50 vuln.db

# show only live URLs from the consolidated list
cat all.txt | httpx -silent

# dedupe and create a timestamped snapshot
sort -u all.txt > snapshots/all-$(date +%F_%H%M).txt
