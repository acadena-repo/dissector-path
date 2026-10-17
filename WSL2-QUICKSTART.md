# WSL2 Quickstart: set up the whole path in about 90 minutes

Goal: a Linux + Rust environment where **everything lives inside WSL2**, and
your Windows tools (VS Code, Wireshark, browser) reach into it. Do this once,
then spend your time on the tutorials, not on tooling.

Blocks marked `PowerShell` run in Windows; blocks marked `Ubuntu` run in the
WSL terminal.

## The picture to keep in your head

```
WINDOWS                                  WSL2 (Ubuntu, a real Linux kernel)
-------                                  ---------------------------------
VS Code (UI only)  <-- Remote WSL -->    VS Code Server, rust-analyzer, terminal
Wireshark (GUI, optional)  --reads-->    ~/projects/dissector-path   (ext4, fast)
Browser / Claude   <-- copy/paste -->    cargo, git, just, tshark, perf...
Downloads\*.zip  --one-time copy-->      (your project, git is the source of truth)
```

Rule of thumb: **tools may live on either side, but the project files and every
build live on the Linux side.**

---

## 1. Install WSL2 and Ubuntu (10 min)

Requirements: Windows 10 (2004+) or Windows 11, and virtualization enabled in
BIOS/UEFI (usually already on).

`PowerShell` (as Administrator):
```powershell
wsl --install -d Ubuntu          # installs WSL2 + the latest Ubuntu LTS
```
Restart if asked, open **Ubuntu** from the Start menu, and create your Linux
username and password (the password is only for `sudo`; no characters appear
while you type).

Verify, in `PowerShell`:
```powershell
wsl -l -v                        # the VERSION column must say 2
wsl --update                     # keep WSL itself current
```
If it says VERSION 1: `wsl --set-version Ubuntu 2`.

Tip: install **Windows Terminal** (Microsoft Store) and pin the Ubuntu profile.
It is a much better terminal than the default window.

Then update Ubuntu, in `Ubuntu`:
```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Why the project must live in `~/projects` (and not under `/mnt/c`)

WSL2 runs Linux in a lightweight VM with its own ext4 disk. Your Windows drives
appear inside it as `/mnt/c`, `/mnt/d`... but that is a *network-style bridge*
between two operating systems (the 9P file protocol), not a real Linux
filesystem.

| | `~/projects/...` (Linux ext4) | `/mnt/c/...` (Windows drive) |
|---|---|---|
| Many small files (`cargo build`, `git status`) | Native speed | Typically several times slower; can be 10x+ on file-heavy work |
| File-change watching (`cargo watch`, rust-analyzer) | Reliable | Often delayed or missed |
| Permissions, symlinks, case sensitivity | Real Linux semantics | Emulated; surprises |
| Line endings | LF | CRLF risks that break scripts |

This matters for the path because Rust builds create thousands of files in
`target/`, and you will rebuild and re-run tests hundreds of times. A slow
filesystem turns every "save, check" cycle into a wait, and waiting kills pace.
Microsoft's own WSL guidance says the same: keep Linux-tool projects on the Linux
filesystem.

Create the home for all your projects, in `Ubuntu`:
```bash
mkdir -p ~/projects
cd ~/projects
pwd        # /home/<you>/projects
```

---

## 3. Get the project into WSL (one time)

You downloaded `dissector-path.zip` into Windows. **Copy it once into the Linux
filesystem, extract it there, and never work from the Windows copy.** Do not
symlink `~/projects` to `/mnt/c`: that brings back every problem in section 2.

Option A, command line, in `Ubuntu`:
```bash
sudo apt install -y unzip zip
# find your Windows user folder from inside WSL:
WINHOME=$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
echo "$WINHOME"                          # e.g. /mnt/c/Users/Ana
cp "$WINHOME/Downloads/dissector-path.zip" ~/projects/
cd ~/projects && unzip dissector-path.zip && rm dissector-path.zip
cd dissector-path && ls
```

Option B, drag and drop: in Windows Explorer's address bar type
`\\wsl.localhost\Ubuntu\home\<your-linux-user>\projects` and drop the zip there,
then `unzip` it in the Ubuntu terminal. (Use your distro name from `wsl -l -v`.)

From now on, **git is your source of truth**. Initialize it now:
```bash
cd ~/projects/dissector-path
git init && git add -A && git commit -m "t00: initial scaffold"
```
Delete the zip in Windows or keep it as a pristine backup; just do not edit it.

---

## 4. Base Linux packages (5 min)

`Ubuntu`:
```bash
sudo apt install -y build-essential pkg-config libssl-dev libpcap-dev \
    git curl wget unzip zip xxd jq htop tcpdump tshark tcpreplay ethtool \
    iproute2 netcat-openbsd
```
What each group is for:
- `build-essential`, `pkg-config`, `libssl-dev`, `libpcap-dev`: compile Rust crates that link C libraries.
- `tcpdump`, `tshark`, `xxd`: look at packets and bytes. `tshark` is your reference dissector in tutorials 03, 07, 08.
- `tcpreplay`, `ethtool`, `iproute2`: lab traffic and NIC settings for tutorial 16.
- `jq`, `htop`: read JSON output, watch CPU and memory.

When `tshark` asks "Should non-superusers be able to capture packets?", answer
**No**. You only read pcap files for now; live capture comes in tutorial 16.

---

## 5. Rust toolchain (10 min, then a few minutes of compiling)

`Ubuntu`:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"                       # load it in this shell (new shells load it automatically)
rustup component add rustfmt clippy rust-analyzer
rustc --version && cargo --version
```
Then the three tools you use every day (compiles from source, a few minutes):
```bash
cargo install --locked just cargo-nextest cargo-watch
```
- `just` runs the project's recipes (`just check`).
- `cargo-nextest` is a faster, clearer test runner.
- `cargo-watch` reruns tests when you save.

You do not need nightly, fuzzers, or profilers yet. Section 12 lists them by
tutorial so you install each one when you reach it.

Tip: `rustup doc --book` opens The Rust Book offline. Keep it one command away.

---

## 6. Git identity and GitHub (5 min)

`Ubuntu`:
```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf input      # never write CRLF into the repo
```
Back up your work off the machine with a **private** GitHub repo. Simplest
login uses the GitHub CLI:
```bash
sudo apt install -y gh
gh auth login                                # choose GitHub.com, HTTPS, login via browser
gh repo create dissector-path --private --source=. --push
```
Commit habit: after every green `just check`, `git commit -m "tNN: summary"`;
`git tag S1`, `S2`... at the end of each tutorial (the tutorials tell you when).

---

## 7. VS Code on Windows, working inside WSL (10 min)

**Do not install VS Code inside Linux.** Install the normal Windows VS Code
(code.visualstudio.com). The *Remote - WSL* extension splits it in two:

- the **window (UI)** runs on Windows;
- a small **VS Code Server** runs inside WSL and does the real work there: file
  access, terminal, rust-analyzer, debugger, git.

So there is **nothing to sync**: you edit the files in `~/projects/...` directly,
and the Windows side only shows them.

Steps:
1. In VS Code (Windows), install the extension **WSL** (`ms-vscode-remote.remote-wsl`).
2. In `Ubuntu`, open the project **from the WSL terminal**:
   ```bash
   cd ~/projects/dissector-path
   code .
   ```
   The first run downloads the VS Code Server into WSL (once). The bottom-left
   corner of the window must show **WSL: Ubuntu**. If it does not, you are
   editing the wrong thing.
3. Install extensions *inside WSL* (the Extensions panel shows an "Install in
   WSL: Ubuntu" button; local-only extensions do not run Linux tools):
   - `rust-lang.rust-analyzer` (language server; essential)
   - `vadimcn.vscode-lldb` (CodeLLDB: debugger)
   - `tamasfe.even-better-toml` (Cargo.toml support)
   - `ms-vscode.hexeditor` (inspect pcap and binary fixtures byte by byte)
   - optional: `usernamehw.errorlens` (shows compiler errors inline)
4. **Important for this project:** the Cargo workspace is in `capstone/`, not at
   the repo root, so rust-analyzer must be told where it is. Create
   `.vscode/settings.json` at the repo root:
   ```json
   {
     "rust-analyzer.linkedProjects": ["capstone/Cargo.toml"],
     "rust-analyzer.check.command": "clippy",
     "editor.formatOnSave": true,
     "[rust]": { "editor.defaultFormatter": "rust-lang.rust-analyzer" },
     "files.watcherExclude": { "**/target/**": true }
   }
   ```
   Clippy on save shows the same lints as `just check`, so you see problems
   while typing instead of at the end.
5. Use the **integrated terminal** (Ctrl+`). In a WSL window it is already your
   Ubuntu shell, in the project folder.

Prefer a JetBrains IDE? RustRover can also open projects in WSL, but this
path assumes VS Code.

Never open `\\wsl$\...` folders directly in a Windows-side editor to edit code;
that crosses the slow bridge. Always start from `code .` in Ubuntu.

---

## 8. Wireshark and sample captures

You have two good options for the GUI:

- **Windows Wireshark** (wireshark.org): install it normally, then open pcaps via
  `\\wsl.localhost\Ubuntu\home\<you>\projects\dissector-path\captures\file.pcap`.
  Reading a pcap across the bridge is fine; it is a one-time read.
- **Inside WSL** (Windows 11 / WSLg): `sudo apt install -y wireshark`, then run
  `wireshark &`. Convenient, slightly heavier.

Command line is your main tool, though:
```bash
tshark -r captures/modbus.pcap -c 1 -V      # full dissection of packet 1
tshark -r captures/modbus.pcap -c 1 -x      # hex dump
```
Download two public captures (Modbus and DNP3 or EtherNet/IP) into
`~/projects/dissector-path/captures/` and note the source in
`captures/SOURCES.md` (see `captures/README.md`). Download in Windows and copy
over with `cp "$WINHOME/Downloads/x.pcap" captures/`, or `wget` straight from
Ubuntu if the URL is direct. Never use customer or work captures.

---

## 9. Give WSL the resources it needs (3 min)

Rust compiles and fuzzing are CPU- and RAM-hungry. By default WSL2 takes part of
your machine; set explicit limits. In Windows, create or edit
`%UserProfile%\.wslconfig` (for example `C:\Users\Ana\.wslconfig`):

```ini
[wsl2]
memory=8GB          # about half your RAM is a good start; 16GB+ machines can give more
processors=6        # leave 2 cores for Windows
swap=4GB
```
Apply it with `PowerShell`: `wsl --shutdown`, then reopen Ubuntu. Check with
`nproc` and `free -h`.

---

## 10. Verify everything with one command

The scaffold includes `scripts/doctor.sh`. In `Ubuntu`:
```bash
cd ~/projects/dissector-path
bash scripts/doctor.sh
```
It checks WSL2, project location, packages, Rust, and tools, and lists anything
missing. Then the real test:
```bash
cd capstone && just check && cargo run -p wg-cli     # prints: wireglass 0.1.0
```
If `just check` fails, copy the whole error to your mentor: the scaffold was
written without a compiler and may need a small fix.

---

## 11. Your daily workflow (memorize this)

```bash
# 1. open Ubuntu (Windows Terminal)
cd ~/projects/dissector-path && code .         # opens the WSL-backed editor
# 2. work in capstone/, tests first
cd capstone && just watch                      # tests rerun on save
# 3. before stopping
just check                                     # fmt + clippy -D warnings + tests
git add -A && git commit -m "tNN: what I did"
```
Handy alias, add to `~/.bashrc`:
```bash
echo "alias wg='cd ~/projects/dissector-path/capstone'" >> ~/.bashrc && source ~/.bashrc
```

### Moving files between WSL, Windows, and Claude
- Open the current Linux folder in Windows Explorer: `explorer.exe .`
- Copy a file's contents to the Windows clipboard: `cat MEMORY.md | clip.exe`
- To upload files to your Claude project: `explorer.exe .`, then drag the files
  (`MEMORY.md` after each update; the others only when they change).
- When the mentor returns an updated `MEMORY.md`: paste it into the file in VS Code
  (WSL window), save, commit.

---

## 12. Install later, when you reach the tutorial

| Tutorial | Install | Command (`Ubuntu`) |
|---|---|---|
| 04 Testing | snapshot review, coverage | `cargo install --locked cargo-insta cargo-llvm-cov` and `rustup component add llvm-tools-preview` |
| 08 Fuzzing | nightly toolchain, fuzzer | `rustup toolchain install nightly` and `cargo install --locked cargo-fuzz` |
| 13 Profiling | flamegraphs, heap profiler | `cargo install flamegraph`, `sudo apt install -y heaptrack` (see perf note below) |
| 16 Capture | kernel feature check | `uname -r` and `zcat /proc/config.gz \| grep -E 'CONFIG_PACKET\|CONFIG_VETH\|CONFIG_BPF'` |
| 19 Packaging | dependency audits, containers | `cargo install --locked cargo-deny cargo-audit`; Docker Desktop with WSL integration |
| 23 Unsafe | Miri, unsafe audit | `rustup +nightly component add miri` and `cargo install --locked cargo-geiger` |

Two honest caveats, to verify when you get there:
- **`perf` on WSL2** is the awkward one. The standard Ubuntu `linux-tools` packages
  target the stock Ubuntu kernel, not Microsoft's WSL kernel, and hardware counters
  are often unavailable inside a VM. Tutorial 13 covers workarounds (build `perf`
  from the WSL2 kernel source, or profile on a native Linux machine).
- **Kernel features for tutorial 16** (`AF_PACKET` rings, `veth` pairs, eBPF/XDP)
  may be limited in the default WSL kernel. Check with the command above; if
  something is missing, options are a custom WSL kernel or a small Linux VM.

---

## 13. Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `code: command not found` in Ubuntu | VS Code not installed on Windows, or not on PATH. Install it, reopen the terminal. Check `wsl --update` and that WSL interop is not disabled in `/etc/wsl.conf`. |
| Everything is slow (builds, git) | The project is under `/mnt/c`. Run `pwd`; move it to `~/projects`. |
| rust-analyzer says "can't find Cargo.toml" | Step 4 of section 7 (`linkedProjects`), or open the `capstone/` folder directly. |
| `cargo: command not found` | Run `. "$HOME/.cargo/env"`; make sure the rustup installer finished. |
| `.wslconfig` has no effect | Run `wsl --shutdown` in PowerShell and reopen Ubuntu. |
| Disk fills up | `target/` folders are big: `cargo clean` in finished experiments. The WSL virtual disk grows but does not auto-shrink; see Microsoft's docs on compacting the VHD (and `wsl --help` for sparse-disk options on recent WSL). |
| `Permission denied` on scripts | `chmod +x script.sh` or run with `bash script.sh`. |
| Odd file encodings or `^M` errors | CRLF line endings. `sed -i 's/\r$//' file` and keep `core.autocrlf input`. |

---

## 14. Back up in two layers

1. **Daily:** `git push` to your private repo (section 6).
2. **Occasionally:** snapshot the whole distro, in `PowerShell`:
   ```powershell
   wsl --export Ubuntu D:\backups\ubuntu-$(Get-Date -Format yyyyMMdd).tar
   ```
   Restore with `wsl --import`.

---

## 15. References and how to keep the pace

Official docs (bookmark these):
- WSL documentation and "Working across file systems": learn.microsoft.com/windows/wsl
- VS Code "Developing in WSL": code.visualstudio.com/docs/remote/wsl
- The Rust Book, Cargo Book, and rustup book: doc.rust-lang.org (also `rustup doc`)
- Pro Git (free): git-scm.com/book
- Wireshark User's Guide and the tshark man page: wireshark.org/docs

Skills you will lean on every day (learn a little, often):
- Shell and tooling: *The Missing Semester of Your CS Education* (MIT, free): shell, git, debugging, profiling lectures.
- *The Linux Command Line* (William Shotts, free online).
- `man <command>` and `<command> --help` before searching the web.

Rules to protect your pace:
1. **Two or three focused sessions a week**, 2 to 3 hours each, beat one marathon.
2. End every session with a green `just check`, a commit, and a note of "next step" in `MEMORY.md`. Starting is then easy.
3. Timebox tooling problems to 20 minutes, then ask your mentor with the exact error and what you tried.
4. Do not install a tool before its tutorial; do not optimize your setup instead of learning.
5. Keep the Rust Book open next to every tutorial. Read the chapter named in the tutorial's prerequisites *before* the hands-on part.
