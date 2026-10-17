# 08. Fuzzing and differential testing

Phase: 2 | Time: ~8 h | Capstone: S7 -> S8
Prerequisites: tutorial 07; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Make every parser entry point fuzzed in CI-friendly ways and automate comparison against tshark, so you trust your dissector on hostile and unusual input.

## Predict first
1. What does coverage-guided fuzzing know that random property testing does not?
2. Which kinds of bugs will a differential test with tshark find, and which kinds will it never find?
3. How do you decide that a fuzzer finding is a bug in your code and not an invalid expectation?

## Parts
### Part 1
`cargo install cargo-fuzz`; create `fuzz/` with targets for `Reader` ops, Ethernet/IP/TCP, Modbus.

### Part 2
Structure-aware fuzzing with `arbitrary` for building semi-valid packets.

### Part 3
Seed corpora from real captures; minimize and merge; run with sanitizers (needs nightly for `cargo fuzz`; document the setup).

### Part 4
Differential harness: a script that runs tshark and `wg` over a capture, normalizes both outputs, and diffs them.

### Part 5
Triage workflow: reproduce, minimize, add a regression fixture, fix, write the lesson in your notes.

## Exercises
1. Run the Modbus target for 30 minutes; report executions per second and coverage growth.
2. Plant a bug (integer overflow in a length) and measure time-to-find for fuzzing vs. proptest.
3. (stretch) Add fuzzing as a scheduled CI job with corpus caching.

## Exit criteria
- [ ] Fuzz targets exist for every public parse entry point built so far
- [ ] A differential test runs on at least two captures and reports zero unexplained differences
- [ ] You fixed at least one fuzz-found issue (real or planted) with a regression test
- [ ] Fuzzing and triage procedure written in `capstone/TESTING.md`
- [ ] `just check` green; MEMORY.md updated; `git tag S8`

## Teach-back
Explain coverage-guided fuzzing in your own words and why a corpus from real captures speeds it up.

## Rust lens (summary)
nightly vs. stable toolchains, `libfuzzer-sys`, `arbitrary` derive, sanitizers, `#[cfg(fuzzing)]`.

## Capstone state after this tutorial
S8: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
cargo-fuzz book; libFuzzer docs; Rust Fuzz Book.
