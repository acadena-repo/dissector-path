# 20. Parser security and evasion

Phase: 5 | Time: ~12 h | Capstone: S19 -> S20
Prerequisites: tutorial 19; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Think like an attacker against your own dissector: resource exhaustion, parser differentials, evasion by fragmentation and overlap, and malformed-input denial of service. Then harden and prove it.

## Predict first
1. What is a parser differential and how can it blind a detection system?
2. Which wire-controlled numbers in your code are still unbounded?
3. How can a passive monitor itself become a safety risk in an industrial network?

## Parts
### Part 1
Attack catalog from your own code: length overflow, allocation bombs, algorithmic complexity, deep nesting, state exhaustion, timing.

### Part 2
Red-team exercise: write hostile generators (not for use on live networks; lab only) for each class.

### Part 3
Resource limits: per-packet CPU budget, per-flow and global memory, max depth and counts; make limits configurable and observable.

### Part 4
Differential and ambiguity handling: record where your interpretation could differ from real devices and surface it as an anomaly.

### Part 5
Review checklist adopted into your PR process.

## Exercises
1. Run your hostile generators against the service and chart memory and CPU.
2. Add an 'anomaly' record type for ambiguity cases and test it.
3. (stretch) Review a public CVE for a protocol parser and write how your design would or would not have prevented it.

## Exit criteria
- [ ] Every wire-controlled quantity is bounded; list and tests exist
- [ ] Hostile-input suite runs in CI within a time budget
- [ ] Resource limits are configurable and metricked
- [ ] Security review checklist committed and used on a self-review
- [ ] `just check` green; MEMORY.md updated; `git tag S20`

## Teach-back
Pick the worst bug class for a passive monitor in an OT network and explain your defense in depth.

## Rust lens (summary)
`checked_*` everywhere, `NonZero` types, `Duration`/budget patterns, `#![forbid(unsafe_code)]` per crate, `cargo geiger` to audit unsafe in dependencies.

## Capstone state after this tutorial
S20: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Ptacek and Newsham (again); published parser CVE write-ups; Suricata/Zeek security advisories.
