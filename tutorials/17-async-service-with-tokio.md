# 17. Async service with tokio

Phase: 4 | Time: ~12 h | Capstone: S16 -> S17
Prerequisites: tutorial 16; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Wrap Wireglass in a long-running service: async control plane (config, health, metrics, output sinks) while the CPU-bound dissection stays on dedicated threads.

## Predict first
1. Why should parsing not run on async executor threads?
2. What does `.await` actually do to a future, and what can go wrong if you hold a lock across it?
3. How do you shut down cleanly with data in flight?

## Parts
### Part 1
Runtime basics: tasks, `spawn`, `select!`, channels; mapping to the existing pipeline.

### Part 2
Bridge sync workers and async sinks with bounded channels and `spawn_blocking` where needed.

### Part 3
Service shell: config (file + env), health endpoint, metrics endpoint, graceful shutdown on SIGINT/SIGTERM.

### Part 4
Output sinks: stdout JSONL, file rotation, a TCP/HTTP sink with retry and backpressure.

### Part 5
Failure modes: slow sink, sink down, config reload.

## Exercises
1. Kill the sink mid-run and observe behavior; define the delivery guarantee you promise (at-most-once or at-least-once) and document it.
2. Add a `/healthz` that reflects capture and worker liveness.
3. (stretch) Hot-reload configuration without dropping flows.

## Exit criteria
- [ ] Service runs, shuts down cleanly with no lost in-flight records beyond the documented guarantee
- [ ] Parsing stays off executor threads (verified by test or tracing)
- [ ] Delivery guarantee documented in an ADR
- [ ] Basic load test shows stable memory and bounded queues
- [ ] `just check` green; MEMORY.md updated; `git tag S17`

## Teach-back
Explain how backpressure travels from a slow sink all the way back to capture, and where you chose to drop.

## Rust lens (summary)
async/await, `Future`, `Pin` at a conceptual level, `tokio::select!`, cancellation safety, `Send` bounds on futures, structured shutdown.

## Capstone state after this tutorial
S17: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Tokio tutorial; Rust Async Book; 'Async: What is blocking?' (Alice Ryhl).
