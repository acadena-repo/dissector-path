# MEMORY.md

> The mentor reads this file at the start of every session and returns a
> complete updated version when you say "Update my MEMORY.md". Keep it
> factual. Ratings change only with evidence.

Last updated: (not yet started)

## 1. Profile (static)
- Goal: expert protocol dissector engineer + senior Rust/Linux backend engineer.
- Starting level: Rust newbie. Other areas: to be calibrated in Session 0.
- Environment: Linux (WSL2 Ubuntu or native). Editor: (fill in)
- Time budget: (hours per week)
- Preferred learning style: build first, theory on demand (adjust if wrong).
- Target date for first full protocol (Modbus): (fill in)

## 2. Progress

Status: `todo`, `doing`, `done` (exit criteria met + teach-back passed).

| # | Tutorial | Status | Date done | Notes |
|---|---|---|---|---|
| 00 | Setup and workflow | todo | | |
| 01 | Ownership, borrowing, slices: hexdump | todo | | |
| 02 | Types and error modeling: Reader | todo | | |
| 03 | Traits, generics, lifetimes: Ethernet/IPv4 | todo | | |
| 04 | Testing: unit, snapshot, property | todo | | |
| 05 | pcap/pcapng reader | todo | | |
| 06 | Layered parsing: VLAN, IPv6, UDP, TCP | todo | | |
| 07 | Modbus/TCP dissector | todo | | |
| 08 | Fuzzing and differential testing | todo | | |
| 09 | TCP stream reassembly | todo | | |
| 10 | Flow table and state machines (DNP3) | todo | | |
| 11 | Dissector framework | todo | | |
| 12 | EtherNet/IP and CIP | todo | | |
| 13 | Benchmarking and profiling | todo | | |
| 14 | Allocation and data layout | todo | | |
| 15 | Concurrency and flow sharding | todo | | |
| 16 | Linux capture: AF_PACKET, ring buffers | todo | | |
| 17 | Async service with tokio | todo | | |
| 18 | Output schema, observability | todo | | |
| 19 | Architecture, packaging, CI/CD | todo | | |
| 20 | Parser security and evasion | todo | | |
| 21 | Reverse engineering an unknown protocol | todo | | |
| 22 | Protocol pack: S7comm, IEC-104, OPC UA | todo | | |
| 23 | Unsafe, FFI, SIMD | todo | | |
| 24 | Staff-level capstone defense | todo | | |

## 3. Skill ratings (0-5, scale in ROADMAP.md)

| Skill | Rating | Evidence / last changed |
|---|---|---|
| Rust language fundamentals | 0 | newbie (self-reported) |
| Idiomatic Rust and API design | 0 | |
| Error handling and parser robustness | ? | calibrate in Session 0 |
| Testing, property tests, fuzzing | ? | |
| Network stacks (L2-L4) | ? | |
| TCP streams and reassembly | ? | |
| Dissection craft (framing, state) | ? | |
| ICS/OT protocols | ? | |
| Performance and profiling | ? | |
| Linux systems programming | ? | |
| Concurrency and async | ? | |
| Security mindset for parsers | ? | |
| Architecture and services | ? | |
| Reverse engineering | ? | |
| Communication, design docs, mentoring | ? | |

## 4. Decisions (ADR index)

| ADR | Title | Status | Date |
|---|---|---|---|
| (none yet) | | | |

## 5. Weak spots (open)

| Date | Weak spot | Evidence | Drill assigned | Status |
|---|---|---|---|---|
| (none yet) | | | | open |

## 6. Concepts mastered (teach-back passed)
- (none yet)

## 7. Capstone state (Wireglass)

- State tag: `S0` (scaffold only)
- Crates: `wg-core` (empty), `wg-cli` (prints version)
- Protocols dissected: none
- Test counts: unit 1, property 0, fuzz targets 0, snapshot 0
- Benchmarks: none
- Known issues: none
- Last `just check`: (date and result)

## 8. Session log

| # | Date | Duration | Covered | Outcome |
|---|---|---|---|---|
| 0 | | | Baseline assessment | |

## 9. Next actions
1. Say "Start session" to run Session 0 (baseline assessment).
2. Complete tutorial 00 (setup and workflow).
3. Install tshark and download two public Modbus/DNP3 sample captures.
