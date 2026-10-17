# 15. Concurrency and flow sharding

Phase: 4 | Time: ~12 h | Capstone: S14 -> S15
Prerequisites: tutorial 14; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Scale across cores: shard flows by hash so each flow's state lives on exactly one worker, pass batches over channels, and keep ordering and backpressure correct.

## Predict first
1. Why must both directions of a connection hash to the same shard?
2. What do `Send` and `Sync` mean, and which of your types are neither?
3. Mutex-protected shared flow table versus shared-nothing sharding: which scales and why?

## Parts
### Part 1
Symmetric flow hash; shard selection; per-worker state with no locks.

### Part 2
Pipeline: reader thread -> batcher -> N workers -> merger/output; bounded channels (`crossbeam`).

### Part 3
Ordering guarantees: per-flow ordered, global unordered; timestamps and merge strategy.

### Part 4
Backpressure and drop policy: count drops explicitly, never block the capture silently.

### Part 5
Scalability benchmark: 1, 2, 4, 8 workers; find the bottleneck.

## Exercises
1. Deliberately share the flow table behind a `Mutex`; measure the scaling loss against sharding.
2. Inject a slow worker and observe queue behavior; tune capacity and drop policy.
3. (stretch) Pin threads to cores and examine NUMA effects (document findings).

## Exit criteria
- [ ] Multi-core pipeline with deterministic per-flow results (same output as single-threaded, verified)
- [ ] Scaling curve recorded in `BENCHMARKS.md` with an explanation of the limit
- [ ] Drops and queue depth exposed as metrics
- [ ] ADR: sharding vs. shared state; channel type and capacity
- [ ] `just check` green; MEMORY.md updated; `git tag S15`

## Teach-back
Explain why shared-nothing design usually beats locking for this workload, and one case where it does not.

## Rust lens (summary)
threads, `std::sync::mpsc` vs. `crossbeam`, `Arc`, `Mutex`, `Send`/`Sync` auto traits, scoped threads, `rayon` for batch jobs, data-race freedom in safe Rust.

## Capstone state after this tutorial
S15: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Rust Book ch. 16; 'Rust Atomics and Locks' (Bos); crossbeam docs.
