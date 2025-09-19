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
git clone https://github.com/<your-username>/NuclEye.git
cd NuclEye

# make scripts executable
chmod +x NuclEye.sh emap.py injsqli.sh zql.sh

# ensure required tools are installed (example using Go for some tools)
# go install github.com/projectdiscovery/httpx/cmd/httpx@latest
# go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# ...install nuclei, katana, qsreplace, anew per their docs
