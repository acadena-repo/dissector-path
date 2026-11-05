# MEMORY.md

> The mentor reads this file at the start of every session and returns a
> complete updated version when you say "Update my MEMORY.md". Keep it
> factual. Ratings change only with evidence.

Last updated: 2026-11-04 (after Session 2, borrow-rules drill)

## 1. Profile (static)
- Goal: expert protocol dissector engineer + senior Rust/Linux backend engineer.
- Starting level: Rust newbie. Other areas calibrated in Session 0 (see section 3).
- Environment: WSL2, Ubuntu 26.04 (kernel 6.18 WSL2). Editor: VS Code + rust-analyzer.
- Repo: `~/projects/dissector-path` (Linux filesystem), remote `origin`, branch `main`.
- Scratch crate for throwaway experiments: `~/projects/scratch` (outside the repo).
- Toolchain (doctor.sh, 2026-10-22): rustc/cargo 1.99.1, rustup 1.29.1, just 1.59.0,
  cargo-nextest 0.9.148, cargo-watch 8.5.3, tshark 4.6.4, tcpdump 4.99.6.
- Time budget: ~9 h/week planned (Mon 1h, Thu 2h, Fri 2h, Sat 3h, Sun 3h = 11h with buffer).
- Plan window: 12 weeks, Oct 19, 2026 to Jan 10, 2027 (~110 h).
- Preferred learning style: build first, theory on demand (adjust if wrong).
- Target date for first full protocol (Modbus): Dec 20, 2026 (draft, end of week 9).
- Schedule habit: Monday = short drills; Thu/Fri = reading and tests; Sat/Sun = building.
- Mentor notes on working style:
  - Tends to skip parts of multi-part tasks (T00 Part 4 predictions; teach-back c
    "what happens"; borrow drill predictions on first submission). Mentor must
    require every part before reviewing.
  - Confidence is not calibrated yet: gave 90% on all six drill snippets (missed
    one), 100% on the follow-up. Ask for varied, honest confidence.
  - Asked how to handle "I don't know": agreed workflow is predict (reasoned
    guess + confidence) -> verify with code (failing-assert probe, `dbg!`,
    scratch crate) -> one line on why the guess was wrong.
  - Mentor process fix: never show results (tables, outputs) before the
    prediction is in (mentor slipped once, 2026-11-03).
  - Responds well to concrete, itemized feedback.

## 2. Progress

Status: `todo`, `doing`, `done` (exit criteria met + teach-back passed).

| # | Tutorial | Status | Date done | Notes |
|---|---|---|---|---|
| 00 | Setup and workflow | done | 2026-11-03 | Took ~2 weeks of calendar time (planned weeks 1-2). ADR-0001 needed 3 drafts; teach-back passed after one round of gap-closing |
| 01 | Ownership, borrowing, slices: hexdump | todo | | planned weeks 1-2; now behind by ~1 week |
| 02 | Types and error modeling: Reader | todo | | planned week 3 |
| 03 | Traits, generics, lifetimes: Ethernet/IPv4 | todo | | planned weeks 4-5 |
| 04 | Testing: unit, snapshot, property | todo | | planned weeks 4-5 |
| 05 | pcap/pcapng reader | todo | | planned weeks 6-7 |
| 06 | Layered parsing: VLAN, IPv6, UDP, TCP | todo | | planned weeks 6-7 |
| 07 | Modbus/TCP dissector | todo | | planned weeks 8-9 |
| 08 | Fuzzing and differential testing | todo | | planned week 10 |
| 09 | TCP stream reassembly | todo | | planned weeks 11-12 |
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
| Rust language fundamentals | 1.5 | T00 (was 1): predicted E0384 + `let mut` fix; explained E0382 via ownership moving to `w`; knew `i32` copies; read E0308 and applied `.copied()`. Gaps: confused "out of scope" with "moved"; said `.clone()` where `.cloned()` was needed; thought `get()` dereferences. S2 drill (no change): 5/6 borrow snippets right plus NLL follow-up; missed two `&mut` (E0499) at 90% confidence. Still needs guidance -> stays 1.5 |
| Idiomatic Rust and API design | 1 | T00 (was 0): wrote `byte_at(&[u8], usize) -> Option<u8>` with `get().copied()` (hint 1 + compiler help); argued borrow over clone for zero-copy |
| Error handling and parser robustness | 1 | T00 (was 0.5): turned a panicking index into `Option`; explained Ethernet padding vs IPv4 total length (with prompting); derived FC 04 quantity bound 125 from the 253-byte PDU limit. S2 (no change): proposed `&buf[14..]` as a fix (hides Incomplete); applied the "store offsets, not slices" idea correctly in the drill |
| Testing, property tests, fuzzing | 1.5 | T00: unchanged. Wrongly predicted `cargo test` stops at first failure; then observed per-binary fail-fast (doc-tests skipped). Tests were given, not designed. S2: used failing-assert probes to read runtime values (with guidance) |
| Network stacks (L2-L4) | 1.5 | T00: unchanged. Hand-decoded a Modbus/TCP frame, length arithmetic correct, IHL/data-offset nibble right after hints. Gaps: 1-based offsets, said the unit is "20 bytes" (it is 32-bit words), assumed TCP = 20 B without reading the field, treated Ethernet as fixed (forgot VLAN again) |
| TCP streams and reassembly | ? | Not tested |
| Dissection craft (framing, state) | ? | Not tested |
| ICS/OT protocols | 1 | T00 (was ?): identified MBAP fields and FC 04 Read Input Registers, decoded start address 2258 and count 2, derived the 125-register limit |
| Performance and profiling | ? | Not tested |
| Linux systems programming | 2 | S0: read tcpdump command correctly; missed CAP_NET_RAW and BPF-in-kernel details. T00: setup done alone, doctor.sh 24/24 |
| Concurrency and async | ? | Not tested |
| Security mindset for parsers | 1 | T00 (was 0.5): after correction, names panic -> sensor DoS and C over-read -> info leak (Heartbleed-style). Relapsed in teach-back ("get() avoids accessing unbounded areas"). S2: explained `push` reallocation -> dangling reference (called it a "snapshot" first) |
| Architecture and services | 1 | T00 (was ?): explained workspace benefits (shared config, overview) and lib/bin split after hint; initially called a workspace a "namespace" and gave mocking as the reason |
| Reverse engineering | ? | Not tested |
| Communication, design docs, mentoring | 1 | T00 (was ?): ADR-0001 v1 was ~2 pages, generic, decision contradicted its own context; v2 left 4 of 8 review items unaddressed; v3 acceptable |

## 4. Decisions (ADR index)

| ADR | Title | Status | Date |
|---|---|---|---|
| 0001 | Documentation strategy and decisions traceability (ADRs in `adr/`) | accepted | 2026-11-01 |

## 5. Weak spots (open)

| Date | Weak spot | Evidence | Drill assigned | Status |
|---|---|---|---|---|
| 2026-10-18 | Borrow rules: many `&T` XOR one `&mut T`; why `push` conflicts with a live borrow (reallocation) | S0 Q3. S2 drill (2026-11-04): stated the rule correctly; explained reallocation -> dangling reference; predicted NLL cases right; missed snippet 4 (two `&mut`, E0499) believing `&mut` allows more, not exclusivity | Confirm in Tutorial 01 code | improving |
| 2026-10-18 | Move vs copy; compile error vs runtime crash | S0 Q1. T00: improved (E0382 explained, `i32: Copy`), but mixed scope with ownership and `.clone()` with `.cloned()`. S2: snippet 5 explained correctly (`i32` copy breaks the borrow) | Tutorial 01 | improving |
| 2026-10-18 | Variable-length header chains and offsets | S0 Q4. T00: assumed TCP = 20 B, unit stated as "20 bytes" instead of 32-bit words, forgot VLAN again | Tutorials 03 and 06 | open |
| 2026-10-18 | Untrusted length fields (over-read, huge alloc, overflow wrap) | S0 Q5/5b. T00: improved (total length vs padding, FC 04 bound) | Tutorial 02 (Reader with checked ops), then 20 | improving |
| 2026-10-22 | Which layer catches what: rustc lints vs clippy lints vs runtime bounds checks; panic vs memory over-read | T00: blamed `forbid(unsafe_code)` for a safe `buf[10]` three times; teach-back said `get()` avoids "accessing unbounded areas". S2: predicted `buf.get(14..)` panics on a 10-byte buffer (mixed up `get` with `[]`) | Tutorial 01; re-check with a quick quiz | open |
| 2026-10-25 | 0-based offsets and half-open ranges (`a..b` has `b - a` elements, valid iff `a <= b <= len`) | T00 Part 4: all offsets 1-based; teach-back: called `14..34` "19 bytes". S2: then understood 20 bytes and why end 34 > len 20 panics; thought `14..=33` was a different fix (same range); did not know `get(14..)` returns `Some(&[])` when start == len (verified by probe) | Tutorial 01 (hexdump offset column) | open |
| 2026-11-01 | Concise, project-specific design writing | ADR-0001 took 3 drafts; v2 ignored half the review items | Every ADR; say "won't fix, because..." instead of silently skipping | open |

## 6. Concepts mastered (teach-back passed)
- Cargo toolchain basics: `build`, `test`, `clippy`, `fmt` vs `fmt -- --check` (T00)
- Cargo workspace: shared `Cargo.lock`, `target/`, metadata and lints; lib (`wg-core`) vs bin (`wg-cli`) split so tests, fuzz targets and benches can depend on the library (T00)
- Purpose of `unwrap_used`, `expect_used`, `indexing_slicing`: no panics on wire data (T00)
- Panic-free access with `slice::get` returning `Option` (T00)
- Reading compiler errors top to bottom incl. `help:` (E0382, E0384, E0308, clippy `indexing_slicing`) (T00)

## 7. Capstone state (Wireglass)

- State tag: `S0` (commit `0f7e9cb`, pushed to `origin`)
- Crates: `wg-core` (`VERSION` const, one test), `wg-cli` (binary `wg`, prints `wireglass 0.1.0`)
- Protocols dissected: none in code (one Modbus/TCP frame decoded by hand)
- Test counts: unit 1, property 0, fuzz targets 0, snapshot 0
- Benchmarks: none
- Captures (public, ITI ICS-Security-Tools, logged in `captures/SOURCES.md`, gitignored): `ModbusTCP.pcap`, `EthernetIP-CIP.pcap`, `PROFINET-RT.pcap`
- Known issues: commit `49edadc` mislabeled `t01:` (pushed; not rewritten). doctor.sh marks the `tcpreplay` interface-list warning as `[ ok ]`
- Last `just check`: green on S0 (after reverting the `byte_at` exercise)
- Mentor fixes to tutorial 00 text: repo path `~/projects/dissector-path`, capture name `ModbusTCP.pcap`, field `modbus.func_code`
- Pending: commit of MEMORY.md + tutorial 00 fixes was advised (2026-11-03); not confirmed yet

## 8. Session log

| # | Date | Duration | Covered | Outcome |
|---|---|---|---|---|
| 0 | 2026-10-18 | ~30 min (est.) | Baseline assessment: Rust (move, borrow), networking (L2-L4 offsets), security (untrusted length), testing (unit vs fuzz), Linux (tcpdump); schedule and pacing | Ratings calibrated; 4 weak spots logged; 12-week plan drafted (Modbus target Dec 20, 2026) |
| 1 | 2026-10-21 to 2026-11-03 | several sittings (not timed) | Tutorial 00: environment check, scaffold build, compiler errors (E0382/E0384/E0308/clippy), `third` panic vs `byte_at` `Option`, hand dissection of a Modbus/TCP frame, ADR-0001 (3 drafts), git tag/push, teach-back | T00 done; S0 tagged and pushed; 7 ratings changed; 3 new weak spots |
| 2 | 2026-11-03 to 2026-11-04 | not timed | Ranges follow-up (`14..34` vs `14..` vs `14..=33`, `get` edge cases via failing-assert probes in a scratch crate); "predict, then verify" workflow; borrow-rules drill (6 snippets + NLL follow-up); offsets-instead-of-slices pattern | Borrow rules and move-vs-copy -> improving; no rating changes; lint-layer and ranges weak spots still open |

## 9. Next actions
1. Confirm the commit/push of MEMORY.md and the tutorial 00 fixes.
2. Say "Next tutorial" to start tutorial 01 (hexdump, S0 -> S1, ~6 h). Read Rust Book chapters 3-4 alongside.
3. Schedule check: T01 is ~1 week behind plan. Aim to finish T01 by Nov 15 to protect the Dec 20 Modbus target; if not, re-plan in the next session.
4. In T01, mentor re-checks three open spots in code: `get` vs `[]` (lint layers), half-open range edges, and two `&mut` at once.
5. Time your sittings (rough minutes per session) so the next log entry has real durations.
