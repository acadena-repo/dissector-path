#!/usr/bin/env bash
# Checks the environment for the Protocol Dissector Expert Path.
# Usage (from anywhere inside WSL):  bash ~/projects/dissector-path/scripts/doctor.sh
# Exit code is 1 if a REQUIRED item is missing.

ok=0; miss=0; warn=0

check() {   # check <label> <command> [version args...]   (required)
  local label="$1" cmd="$2"; shift 2
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  [ ok ]    %-14s %s\n' "$label" "$("$cmd" "$@" 2>&1 | head -n1)"
    ok=$((ok + 1))
  else
    printf '  [MISSING] %-14s (%s not found)\n' "$label" "$cmd"
    miss=$((miss + 1))
  fi
}

check_cargo_sub() {   # check_cargo_sub <label> <subcommand>   (required)
  if command -v "cargo-$2" >/dev/null 2>&1; then
    printf '  [ ok ]    %-14s %s\n' "$1" "$(cargo "$2" --version 2>&1 | head -n1)"
    ok=$((ok + 1))
  else
    printf '  [MISSING] %-14s (cargo-%s not found)\n' "$1" "$2"
    miss=$((miss + 1))
  fi
}

note_warn() { printf '  [ warn ]  %s\n' "$1"; warn=$((warn + 1)); }
note_ok()   { printf '  [ ok ]    %s\n' "$1"; ok=$((ok + 1)); }

echo "== Platform"
if grep -qi microsoft /proc/version 2>/dev/null; then
  if uname -r | grep -qi 'wsl2'; then note_ok "WSL2 detected ($(uname -r))"
  else note_warn "WSL detected but kernel name lacks 'WSL2'; run 'wsl -l -v' in PowerShell and confirm VERSION 2"; fi
else
  note_ok "Not WSL (native Linux): fine"
fi

echo "== Project location"
case "$PWD" in
  /mnt/*) note_warn "You are under $PWD (Windows drive). Move the project to ~/projects for speed." ;;
  *)      note_ok "Working directory is on the Linux filesystem ($PWD)" ;;
esac
if [ -d "$HOME/projects/dissector-path" ]; then note_ok "Found ~/projects/dissector-path"
else note_warn "~/projects/dissector-path not found (fine if you put it elsewhere on the Linux filesystem)"; fi

echo "== System packages"
check "gcc"        gcc --version
check "pkg-config" pkg-config --version
check "git"        git --version
check "curl"       curl --version
check "unzip"      unzip -v
check "xxd"        xxd -v
check "jq"         jq --version
check "tshark"     tshark --version
check "tcpdump"    tcpdump --version
check "tcpreplay"  tcpreplay --version
check "ethtool"    ethtool --version

echo "== Rust"
check "rustup" rustup --version
check "rustc"  rustc --version
check "cargo"  cargo --version
if command -v rustup >/dev/null 2>&1; then
  comps=$(rustup component list --installed 2>/dev/null)
  for c in rustfmt clippy rust-analyzer; do
    if printf '%s\n' "$comps" | grep -q "^$c"; then note_ok "rustup component: $c"
    else printf '  [MISSING] rustup component: %s (rustup component add %s)\n' "$c" "$c"; miss=$((miss + 1)); fi
  done
fi
check "just" just --version
check_cargo_sub "nextest"     nextest
check_cargo_sub "cargo-watch" watch

echo "== Git identity"
if [ -n "$(git config --global user.name 2>/dev/null)" ] && [ -n "$(git config --global user.email 2>/dev/null)" ]; then
  note_ok "git user.name and user.email set"
else
  printf '  [MISSING] git identity (git config --global user.name/user.email)\n'; miss=$((miss + 1))
fi

echo
echo "Summary: $ok ok, $warn warning(s), $miss missing"
if [ "$miss" -gt 0 ]; then echo "Fix the MISSING items (see WSL2-QUICKSTART.md), then rerun."; exit 1; fi
echo "Environment looks ready. Next: cd capstone && just check"
