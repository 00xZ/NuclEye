#!/usr/bin/env bash
# setup-nucleyes-tools.sh
# Installs the minimal toolset used by NuclEye:
# httpx, subfinder, katana, nuclei, qsreplace, gdn, anew
# Designed for Debian/Ubuntu-like systems. Adjust package manager as needed.

set -euo pipefail
IFS=$'\n\t'

# CONFIG
GO_PKGS=(
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/katana/cmd/katana@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/tomnomnom/qsreplace@latest"
  "github.com/kmskrishna/gdn@latest"
  "github.com/tomnomnom/anew@latest"
)
BIN_DIR="/usr/local/bin"
GOBIN_DEFAULT="$HOME/go/bin"

echo "=== NuclEye: minimal tool installer ==="
echo

# Helper: print and run
run() { echo -e "\n\$ $*"; "$@"; }

# 1) Install system packages if apt is available
if command -v apt >/dev/null 2>&1; then
  echo "Detected apt package manager — installing system deps (git, curl, build-essential, python3, unzip, ca-certificates)..."
  sudo apt update
  sudo apt install -y git curl ca-certificates build-essential python3 python3-pip unzip
else
  echo "apt not found. Please ensure git, go (1.20+ / 1.21+ recommended), python3 are installed on your system."
fi

# 2) Ensure Go is installed
if ! command -v go >/dev/null 2>&1; then
  echo "Go not found in PATH. Attempting to install golang via apt (if available)..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt install -y golang-go
  fi
fi

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: go is not installed or not in PATH. Install Go (1.21+ recommended) and re-run this script."
  exit 1
fi

echo "Go version: $(go version)"
mkdir -p "$GOBIN_DEFAULT"

# 3) Ensure GOPATH/bin (or GOBIN) is in PATH for current session
GOBIN="${GOBIN:-$GOBIN_DEFAULT}"
export PATH="$PATH:$GOBIN"

# 4) Install each Go package with 'go install'
echo
echo "Installing Go tools..."
for pkg in "${GO_PKGS[@]}"; do
  echo
  echo ">>> go install $pkg"
  # katana may require CGO enabled for some environments, enable it for all installs (safe)
  CGO_ENABLED=1 GOFLAGS="" go install -v "$pkg"
done

# 5) Move/copy binaries from $GOBIN to $BIN_DIR so they're globally available
mkdir -p "$BIN_DIR"
echo
echo "Copying binaries to $BIN_DIR (requires sudo)..."

# Known binary names we expect from packages (map pkg->bin)
declare -a BINARIES=("httpx" "subfinder" "katana" "nuclei" "qsreplace" "gdn" "anew")

for bin in "${BINARIES[@]}"; do
  src="$GOBIN/$bin"
  if [ -f "$src" ]; then
    echo "Installing $bin -> $BIN_DIR/$bin"
    sudo cp "$src" "$BIN_DIR/$bin"
    sudo chmod +x "$BIN_DIR/$bin"
  else
    # sometimes binary name differs or is not found; try to detect in GOPATH
    alt="$(ls "$GOBIN" 2>/dev/null | grep -x "$bin" || true)"
    if [ -n "$alt" ]; then
      sudo cp "$GOBIN/$alt" "$BIN_DIR/$bin"
      sudo chmod +x "$BIN_DIR/$bin"
      echo "Installed $bin (alternate found)"
    else
      echo "Warning: $bin not found in $GOBIN. You may need to build/download it manually."
    fi
  fi
done

# 6) Post-install: nuclei-templates clone (templates are required by nuclei)
if [ ! -d "$HOME/nuclei-templates" ]; then
  echo
  echo "Cloning nuclei-templates into $HOME/nuclei-templates"
  git clone https://github.com/projectdiscovery/nuclei-templates.git "$HOME/nuclei-templates" || true
else
  echo "nuclei-templates already present in $HOME/nuclei-templates (skipping clone)"
fi

# 7) Quick checks
echo
echo "=== Quick checks ==="
for bin in "${BINARIES[@]}"; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "OK: $bin -> $(command -v $bin)"
  else
    echo "MISSING: $bin (not found in PATH)"
  fi
done

echo
echo "Finished. If any tool is missing, install it manually or check $GOBIN for binaries."
echo "Tip: add 'export PATH=\"\$PATH:$GOBIN\"' to your shell rc file (e.g. ~/.bashrc) to use go-installed binaries directly."
