# 14. Allocation and data layout

Phase: 4 | Time: ~10 h | Capstone: S13 -> S14
Prerequisites: tutorial 13; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Remove avoidable allocations and copies on the hot path using evidence from profiles: borrowed data, `bytes`, `SmallVec`, arenas, and cache-aware layouts.

## Predict first
1. Where does your current pipeline allocate per packet? Predict, then verify with a profiler.
2. When is `SmallVec` slower than `Vec`?
3. What does 'cache-friendly' mean for a table of flows?

## Parts
### Part 1
Allocation census from tutorial 13 data; rank by cost.

### Part 2
Replace owned buffers with borrowed slices or `bytes::Bytes` where lifetimes allow; discuss lifetime ergonomics trade-offs.

### Part 3
Small-collection optimizations (`SmallVec`, `ArrayVec`) and reusable buffers (object pools, `clear()` and reuse).

### Part 4
Flow table layout: key hashing (`ahash`/`fxhash` vs. SipHash and DoS resistance), struct-of-arrays vs. array-of-structs.

### Part 5
Re-benchmark after each change individually.

## Exercises
1. Reduce allocations per packet to near zero on the Modbus path; report counts before and after.
2. Compare hashers for the flow table and discuss the security trade-off of non-keyed hashes.
3. (stretch) Try an arena allocator (`bumpalo`) for per-packet temporaries.

## Exit criteria
- [ ] Documented allocation reduction with numbers
- [ ] No regression in correctness (all snapshot, property, and differential tests green)
- [ ] ADR on hasher choice and lifetime vs. `Bytes` ownership model
- [ ] You can name two optimizations you rejected because the numbers did not justify them
- [ ] `just check` green; MEMORY.md updated; `git tag S14`

## Teach-back
Explain one optimization you rejected and the evidence that led you to reject it.

## Rust lens (summary)
`Bytes` vs. `&[u8]`, `Cow`, `SmallVec`, `Vec::with_capacity`, `clear()` reuse, `Hasher` traits, `size_of` and `repr`, avoiding `Box` per item.

## Capstone state after this tutorial
S14: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Rust Performance Book chapters on allocation and hashing; `bytes` and `bumpalo` docs.
