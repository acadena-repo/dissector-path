# 23. Unsafe, FFI, SIMD

Phase: 5 | Time: ~12 h | Capstone: S22 -> S23
Prerequisites: tutorial 22; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Understand when and how to use `unsafe` responsibly: FFI to C libraries, SIMD for hot loops, and auditing. Most of Wireglass should remain 100% safe; you learn to decide why.

## Predict first
1. What exactly does `unsafe` allow, and what does it not turn off?
2. What are the soundness rules for a safe wrapper around unsafe code?
3. Where might SIMD help a dissector (searching, checksums) and where is it a distraction?

## Parts
### Part 1
Rustonomicon essentials: aliasing, validity invariants, uninitialized memory, `MaybeUninit`, `repr(C)`.

### Part 2
FFI: call a small C function and wrap it; then expose a Rust API as C (`cbindgen`) and discuss a plugin boundary.

### Part 3
SIMD: use `memchr` and portable `std::simd` or `std::arch` for checksum or delimiter search; measure.

### Part 4
Verification tools: Miri, sanitizers, `cargo geiger`, fuzzing the unsafe boundary.

### Part 5
Decide, by evidence, whether any unsafe belongs in the hot path.

## Exercises
1. Run Miri on your ring buffer wrapper from tutorial 16 and fix what it finds.
2. Implement the IPv4 checksum with and without SIMD; chart the results.
3. (stretch) Write a C-ABI function that parses Modbus and call it from a C test program.

## Exit criteria
- [ ] Every unsafe block has a safety comment and a test; Miri clean where applicable
- [ ] FFI example with ownership rules documented
- [ ] SIMD experiment with a measured verdict recorded in an ADR
- [ ] You can explain why safe wrappers must be sound for *all* callers
- [ ] `just check` green; MEMORY.md updated; `git tag S23`

## Teach-back
Explain a soundness bug you could introduce in a safe-looking wrapper, and how to prevent it.

## Rust lens (summary)
`unsafe` blocks/functions/traits, `MaybeUninit`, raw pointers, `repr(C)`, `std::arch`, Miri, `cbindgen`/`bindgen`.

## Capstone state after this tutorial
S23: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
The Rustonomicon; Miri docs; 'Learn Rust With Entirely Too Many Linked Lists'.
