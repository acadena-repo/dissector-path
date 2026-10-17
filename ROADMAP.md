# ROADMAP.md

Six phases, 25 tutorials (00-24), one evolving capstone (Wireglass).
Rust fundamentals are front-loaded (Phase 1) but always taught on dissector
material.

## Pacing

At 8-10 hours per week, expect about 8-10 months. At 5 hours per week, about
14-16 months. Never trade exit criteria for speed: a skipped criterion shows up
as a weak spot two tutorials later.

## Skill scale (0-5)

| Level | Meaning |
|---|---|
| 0 | Never done it |
| 1 | Can follow a tutorial with guidance |
| 2 | Can do it alone on a familiar problem, with docs |
| 3 | Can do it on new problems, and explain trade-offs |
| 4 | Can design it, review others' work, and spot subtle bugs |
| 5 | Can teach it, set the team standard, and handle ambiguous or novel cases |

Targets: Staff-level means 4 in most rows and 5 in robustness, testing, and
architecture of dissection.

## Phases and tutorials

### Phase 0: Setup
| # | Tutorial | Capstone out-state |
|---|---|---|
| 00 | Setup and workflow | S0 scaffold builds, first ADR |

### Phase 1: Rust through bytes (newbie to confident)
| # | Tutorial | Key Rust | Capstone out-state |
|---|---|---|---|
| 01 | Ownership, borrowing, slices: hexdump | ownership, `&[u8]`, iterators | S1 `hexdump` |
| 02 | Types and error modeling: Reader | enums, `Result`, `?`, newtypes | S2 `Reader`, `ParseError` |
| 03 | Traits, generics, lifetimes: Ethernet/IPv4 | traits, lifetimes, zero-copy | S3 L2/L3 parsers |
| 04 | Testing: unit, snapshot, property | `#[cfg(test)]`, insta, proptest | S4 test harness |

### Phase 2: Network foundations and the first dissector
| # | Tutorial | Key Rust | Capstone out-state |
|---|---|---|---|
| 05 | pcap/pcapng reader | I/O, iterators, modules | S5 file reader |
| 06 | Layered parsing: VLAN, IPv6, UDP, TCP | enum dispatch, composition | S6 L2-L4 stack |
| 07 | Modbus/TCP dissector | incremental parsing | S7 Modbus |
| 08 | Fuzzing and differential testing | cargo-fuzz, tshark diff | S8 fuzzed Modbus |

### Phase 3: Streams, state, and framework
| # | Tutorial | Key Rust | Capstone out-state |
|---|---|---|---|
| 09 | TCP stream reassembly | `BTreeMap`, bounded buffers | S9 reassembler |
| 10 | Flow table and state machines (DNP3) | state enums, `HashMap` entry API | S10 DNP3 |
| 11 | Dissector framework | trait objects vs generics | S11 registry |
| 12 | EtherNet/IP and CIP | nested layers, `Cow` | S12 ENIP/CIP |

### Phase 4: Performance and Linux systems
| # | Tutorial | Key Rust | Capstone out-state |
|---|---|---|---|
| 13 | Benchmarking and profiling | criterion, perf, flamegraph | S13 baselines |
| 14 | Allocation and data layout | `bytes`, `SmallVec`, arenas | S14 allocation-lean path |
| 15 | Concurrency and flow sharding | threads, channels, `Send`/`Sync` | S15 multi-core pipeline |
| 16 | Linux capture: AF_PACKET, ring buffers | `libc`, syscalls, safe wrappers | S16 live capture |
| 17 | Async service with tokio | async/await, backpressure | S17 service shell |

### Phase 5: Production, security, and staff scope
| # | Tutorial | Key Rust | Capstone out-state |
|---|---|---|---|
| 18 | Output schema and observability | serde, tracing, metrics | S18 structured output |
| 19 | Architecture, packaging, CI/CD | workspaces, features, containers | S19 deployable |
| 20 | Parser security and evasion | resource limits, adversarial tests | S20 hardened |
| 21 | Reverse engineering an unknown protocol | tooling, hypothesis testing | S21 custom protocol |
| 22 | Protocol pack: S7comm, IEC-104, OPC UA | macros, code reuse | S22 multi-protocol |
| 23 | Unsafe, FFI, SIMD | `unsafe` discipline, `memchr` | S23 audited unsafe |
| 24 | Staff-level capstone defense | design docs, review | S24 final |

## Milestones

| Milestone | After | You can say |
|---|---|---|
| M1 Rust-literate | 04 | "I can write and test safe, idiomatic Rust parsers" |
| M2 First real dissector | 08 | "I shipped a fuzzed, tshark-validated Modbus dissector" |
| M3 Stateful dissection | 12 | "I handle streams, state, and layered ICS protocols" |
| M4 Systems-grade | 17 | "I measure, optimize, and run it live on Linux" |
| M5 Staff-ready | 24 | "I design the framework, set the standards, and defend trade-offs" |

## Rules of the road

- One tutorial = one capstone increment, one ADR (at least), and updated tests.
- A tutorial is `done` only when all exit criteria and the teach-back pass.
- Revisit weak spots listed in MEMORY.md before starting a new tutorial.
- Re-assess skill ratings at M1 to M5 with a short oral exam from the mentor.
