# 00. Setup and workflow

Phase: 0 | Time: ~3 h | Capstone: (none) -> S0
Prerequisites: none
Status: full

## Goal
Get a reproducible Linux + Rust environment, build the Wireglass scaffold,
learn the daily workflow (`just check`), look at real ICS traffic in Wireshark,
and write your first ADR. After this tutorial, nothing about tooling should
distract you from learning.

## Predict first
1. What do you expect `cargo build` to download or create, and where?
2. If a test fails, will `cargo test` stop at the first failure or run all?
3. Why might a team forbid `unwrap()` in a network parser but allow it in tests?

## Parts

### Part 1: Environment
Follow `WSL2-QUICKSTART.md` (repo root) first: it installs WSL2, the Linux
packages, Rust, git, and VS Code in the right order, and `scripts/doctor.sh`
verifies the result. Keep the project inside the Linux filesystem
(`~/projects/dissector-path`), not under `/mnt/c`, for speed. Do not install
`perf` yet (tutorial 13 covers its WSL2 caveats).

Editor: VS Code with the `rust-analyzer` extension, or any editor with LSP
support. Turn on "format on save" and "clippy on save".

Rust lens: `rustup` manages toolchains, `cargo` is build tool, test runner,
dependency manager, and doc generator. `rust-toolchain.toml` pins the channel
for everyone who clones the project.

### Part 2: Build the scaffold
```bash
cd ~/dissector-path
git init
cd capstone
just check
cargo run -p wg-cli          # prints: wireglass 0.1.0
```
Read `capstone/Cargo.toml`. Identify: workspace members, shared package
metadata, shared lints. Then answer: what does `unsafe_code = "forbid"` do,
and why is it a good default for this project?

If `just check` fails, copy the full error to your mentor. The scaffold was
written without a compiler, so it may need a small fix.

### Part 3: Learn to read the compiler
Break things on purpose, one at a time, and read each error fully:
1. In `wg-core/src/lib.rs`, change the test to `assert!(VERSION.is_empty());`.
   Run `cargo test`. Where is the failing line reported?
2. Add `let x = 5; x = 6;` in a function. Read the error and the suggestion.
3. Add `let v = vec![1, 2, 3]; let w = v; println!("{:?}", v);`. Predict
   the error before running. Then explain it in one sentence.
4. Add `let a = buf[10];` on a `&[u8]` parameter. `cargo clippy` should flag
   it via `indexing_slicing`. Why does this matter for parsers?

Rust lens: compiler messages in Rust are teaching tools. Always read them
top to bottom, including the `help:` lines. Run `rustc --explain E0382` for
a long explanation of an error code.

### Part 4: Look at real traffic
Download one public Modbus/TCP capture and one DNP3 or EtherNet/IP capture
into `captures/` (see `captures/README.md`; log the sources in
`captures/SOURCES.md`).

```bash
tshark -r captures/modbus.pcap | head
tshark -r captures/modbus.pcap -V -c 1          # full dissection of packet 1
tshark -r captures/modbus.pcap -x -c 1          # hex + ASCII
tshark -r captures/modbus.pcap -T fields -e frame.number -e ip.src -e ip.dst -e mbtcp.func_code
```
Open the same file in the Wireshark GUI. Pick one packet, click through the
layers (Ethernet, IP, TCP, Modbus), and watch which bytes light up for each
field.

Write down: how many bytes is each header? Which header contains the length
of the next? That observation is the seed of tutorial 03.

### Part 5: Your first ADR
Copy `templates/ADR_TEMPLATE.md` to `adr/0001-record-decisions.md`. Decide:
"We record significant design decisions as ADRs." Fill context, two options
(ADRs vs. commit messages only), decision, and consequences. Keep it under
half a page. Commit.

### Part 6: Git hygiene
Commit after every green `just check`. Message format: `tNN: short summary`.
Tag the end of each tutorial: `git tag S0`, `S1`, and so on, so you can
return to any capstone state.

## Exercises
1. (core) Run `cargo doc --open` and find `wg_core::VERSION` in the output.
2. (core) Run `cargo nextest run` and compare with `cargo test`.
3. (stretch) Write a shell one-liner using `tshark -T fields` that counts
   packets per Modbus function code in your capture.
4. (stretch) Read `rust-analyzer` hover docs for `Result` and `Option`.

## Exit criteria
- [ ] `just check` is green on a fresh clone
- [ ] You can explain what `cargo build`, `cargo test`, `cargo clippy`, `cargo fmt` each do
- [ ] You triggered and understood at least three compiler errors (Part 3)
- [ ] You dissected one real packet by eye from a tshark `-x` dump (header sizes noted)
- [ ] ADR-0001 is written and committed; `git tag S0` exists
- [ ] Two public captures are in `captures/` with sources logged

## Teach-back
Without notes: explain to your mentor what a Cargo workspace is, why this
project uses one, and what the three lints in `[workspace.lints.clippy]`
protect against.

## Rust lens (summary)
Toolchain, `cargo` subcommands, reading compiler errors, lint configuration,
why `unwrap` and indexing are banned in library code.

## Capstone state after this tutorial
S0: workspace with `wg-core` (version const, one test) and `wg-cli`.

## Further reading
The Rust Book chapters 1-3. Cargo Book: workspaces. `man tshark`.
