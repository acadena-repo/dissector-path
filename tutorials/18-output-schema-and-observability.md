# 18. Output schema and observability

Phase: 5 | Time: ~10 h | Capstone: S17 -> S18
Prerequisites: tutorial 17; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Make the output a stable contract and the system observable: versioned schemas, structured logs and traces, metrics, and per-protocol health signals.

## Predict first
1. What breaks downstream when you rename a field? How do you make that impossible by accident?
2. What metrics would tell you a dissector is silently failing on a new firmware version?
3. Logs, metrics, traces: what question does each answer best?

## Parts
### Part 1
Schema design: `serde` types, JSON Lines vs. protobuf (`prost`); compatibility rules and a version field.

### Part 2
Golden-file contract tests for the schema; a breaking-change checklist.

### Part 3
`tracing` spans and structured events with sampling for hot paths; `metrics` counters and histograms.

### Part 4
Per-protocol health: parse success, incomplete, malformed, unsupported ratios; alert thresholds.

### Part 5
Redaction and data minimization: what you must not log from payloads.

## Exercises
1. Write a schema-evolution test: old consumer reads new output.
2. Create a dashboard sketch (queries) for dissector health.
3. (stretch) Emit OpenTelemetry-compatible traces.

## Exit criteria
- [ ] Versioned, documented output schema with contract tests
- [ ] Metrics and logs sufficient to detect a regression in one dissector (demonstrate with a planted bug)
- [ ] Hot-path logging cost measured and acceptable
- [ ] ADR: JSON vs. protobuf and the versioning policy
- [ ] `just check` green; MEMORY.md updated; `git tag S18`

## Teach-back
Explain how you would detect that a new device firmware silently broke your Modbus parsing in production.

## Rust lens (summary)
`serde` derives and attributes, `#[serde(default)]`, `tracing` macros and subscribers, feature flags, avoiding allocation in log paths.

## Capstone state after this tutorial
S18: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
`serde` book, `tracing` docs, Google SRE book chapters on monitoring.
