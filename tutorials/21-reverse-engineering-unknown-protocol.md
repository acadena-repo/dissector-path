# 21. Reverse engineering an unknown protocol

Phase: 5 | Time: ~14 h | Capstone: S20 -> S21
Prerequisites: tutorial 20; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Derive the structure of an undocumented protocol from captures: find framing, fields, enums and checksums by differential analysis, then implement and validate a dissector.

## Predict first
1. How do you find a length field with no documentation?
2. How do you tell a counter from a checksum from random data?
3. How many captures are enough before you trust a hypothesis?

## Parts
### Part 1
Choose a lab protocol (a small custom one, an open-source device simulator, or a public capture of a lesser-known protocol).

### Part 2
Tooling: statistical byte analysis per offset (entropy, cardinality, monotonicity), message clustering, diffing request/response pairs.

### Part 3
Hypothesis log: field, offset, evidence, confidence; update as you learn.

### Part 4
Implementation via the framework; mark guessed fields as 'inferred' in output.

### Part 5
Validation: hold-out captures, generate variations from a simulator if available.

## Exercises
1. Write a Rust analysis tool that prints per-offset statistics for a set of messages.
2. Identify the checksum algorithm candidates (CRC-8/16/32, sum, XOR) with a brute-force tool.
3. (stretch) Hand the findings to a teammate as a spec and have them review it.

## Exit criteria
- [ ] Protocol spec document written from observation alone
- [ ] Dissector implemented, tested on held-out captures, with confidence marked per field
- [ ] Analysis tool committed in a `tools/` crate
- [ ] Lessons-learned note: what was easy, what was ambiguous
- [ ] `just check` green; MEMORY.md updated; `git tag S21`

## Teach-back
Explain your method to a reverse engineer colleague and where you would ask them for help (disassembly, firmware).

## Rust lens (summary)
small CLI tools with `clap`, data analysis in plain Rust (`itertools`), CSV output, error handling with `anyhow` in binaries.

## Capstone state after this tutorial
S21: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Public reverse-engineering write-ups of ICS protocols; Wireshark Lua/Rust plugin docs.
