# 13. Benchmarking and profiling

Phase: 4 | Time: ~10 h | Capstone: S12 -> S13
Prerequisites: tutorial 12; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Learn to measure honestly: microbenchmarks with criterion, end-to-end throughput on real captures, CPU profiles with perf and flamegraphs, and a baseline you can compare against.

## Predict first
1. Why is a benchmark that parses one 60-byte packet in a loop misleading?
2. What is the difference between latency and throughput for a dissection pipeline?
3. How can you tell whether time is spent in your code, in allocation, or in I/O?

## Parts
### Part 1
Workload design: representative pcaps scaled up; define metrics (packets/s, MB/s, ns/packet, p99).

### Part 2
criterion benches per layer and per dissector; avoid optimizer artifacts with `black_box`.

### Part 3
End-to-end bench: `wg dissect` over a large file; `perf stat`, `perf record`, `cargo flamegraph`.

### Part 4
Allocation profiling: `dhat` or `heaptrack`; count allocations per packet.

### Part 5
Record baselines in `capstone/BENCHMARKS.md` with machine info and commit hash.

## Exercises
1. Find the top 3 hot functions on your Modbus workload and hypothesize why before looking at the code.
2. Compare `--release` vs. debug and `lto = "thin"`, `codegen-units = 1`: measure each separately.
3. (stretch) Use `perf` hardware counters to compare cache misses between two data layouts.

## Exit criteria
- [ ] Reproducible benchmark suite with documented baselines
- [ ] A flamegraph and an allocation profile for the main workload, annotated in your notes
- [ ] One optimization hypothesis tested with before/after numbers (accepted or rejected)
- [ ] You can explain noise, warm-up, and why you report distributions
- [ ] `just check` green; MEMORY.md updated; `git tag S13`

## Teach-back
Explain how you would prove to a skeptic that a change made the dissector faster.

## Rust lens (summary)
release profiles, `black_box`, `criterion`, `#[inline]` and its limits, reading assembly with `cargo asm` (optional).

## Capstone state after this tutorial
S13: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
The Rust Performance Book; Brendan Gregg's perf and flamegraph material; criterion user guide.
