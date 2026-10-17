# 19. Architecture, packaging, CI/CD

Phase: 5 | Time: ~12 h | Capstone: S18 -> S19
Prerequisites: tutorial 18; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Package and ship Wireglass like a product: crate and service boundaries, a release pipeline, containers/systemd deployment, and an architecture document you could defend in a design review.

## Predict first
1. Which parts of Wireglass should be libraries, which binaries, and which separate services?
2. What belongs in CI that is too slow for every commit?
3. How do you run a passive capture container safely (capabilities, network mode)?

## Parts
### Part 1
Architecture doc: context, containers, data flow, failure modes, scaling limits, security boundaries.

### Part 2
CI pipeline: fmt, clippy, tests, `cargo deny`/`cargo audit`, coverage, scheduled fuzz and benchmarks.

### Part 3
Reproducible builds: `Cargo.lock`, pinned toolchain, static linking with musl where appropriate (discuss allocator and performance trade-offs).

### Part 4
Container image (multi-stage) and a systemd unit; minimal capabilities (`CAP_NET_RAW`), non-root, read-only filesystem.

### Part 5
Release process: versioning, changelog, signed artifacts.

## Exercises
1. Produce a threat model for the service (assets, trust boundaries, attacker inputs).
2. Add `cargo deny` and fix or justify findings.
3. (stretch) Compare glibc vs. musl builds on throughput.

## Exit criteria
- [ ] One-command release build and container image
- [ ] CI green with security and dependency checks
- [ ] Architecture doc and threat model reviewed by your mentor
- [ ] Deployment runs as non-root with only required capabilities
- [ ] `just check` green; MEMORY.md updated; `git tag S19`

## Teach-back
Present the architecture in 10 minutes and defend three trade-offs.

## Rust lens (summary)
workspaces and feature flags at scale, MSRV policy, `cargo deny`, build scripts (`build.rs`) and when to avoid them, cross-compilation.

## Capstone state after this tutorial
S19: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Cargo Book; Docker and systemd security hardening docs; SLSA basics.
