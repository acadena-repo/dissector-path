# 11. Dissector framework

Phase: 3 | Time: ~12 h | Capstone: S10 -> S11
Prerequisites: tutorial 10; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Design the extensible architecture other engineers will use: a dissector interface, a registry with port and heuristic detection, uniform output records, and clean error and metrics hooks.

## Predict first
1. Generics, trait objects, or enums for a set of dissectors: what does each cost in speed, binary size, and extensibility?
2. How should protocol detection work when the port is non-standard?
3. What is the minimal information every dissector must emit so downstream code can stay protocol-agnostic?

## Parts
### Part 1
Requirements and non-goals doc; write an ADR comparing three designs before coding.

### Part 2
`wg-dissect`: `Dissector` trait (stream-oriented and datagram-oriented), `Registry`, `Detection` (port, heuristic probe returning confidence).

### Part 3
Uniform `Record` type: timestamp, flow, protocol, message summary, risk tags, anomalies.

### Part 4
Per-dissector metrics counters (parsed, incomplete, malformed, unsupported).

### Part 5
Port Modbus and DNP3 to the framework unchanged in behavior (refactor under tests).

## Exercises
1. Add a heuristic detector for Modbus on non-standard ports and test false positives on DNP3 and random data.
2. Benchmark dyn dispatch vs. enum dispatch on one capture (preview of tutorial 13).
3. (stretch) Dissector plugin discovery at compile time with `inventory`-style registration or feature flags.

## Exit criteria
- [ ] Both existing dissectors run through the registry with identical output to before (snapshot tests)
- [ ] Adding a dissector requires touching at most the new crate plus one registration line
- [ ] Framework documented with an example and a 'how to add a protocol' guide
- [ ] ADR with the rejected alternatives and measured or reasoned costs
- [ ] `just check` green; MEMORY.md updated; `git tag S11`

## Teach-back
Defend your dispatch choice to a skeptical reviewer, including when you would reverse it.

## Rust lens (summary)
trait design, object safety, `dyn Trait` vs. generics, associated types, builder pattern, API Guidelines checklist, semver and `#[non_exhaustive]`.

## Capstone state after this tutorial
S11: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Rust API Guidelines; Rust Design Patterns; Zeek and Suricata parser registration code.
