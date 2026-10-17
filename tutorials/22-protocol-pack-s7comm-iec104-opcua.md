# 22. Protocol pack: S7comm, IEC-104, OPC UA

Phase: 5 | Time: ~18 h | Capstone: S21 -> S22
Prerequisites: tutorial 21; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Scale the framework with three more protocols of different shapes, to prove the architecture and to practice repeating the whole dissector workflow quickly and safely.

## Predict first
1. Which of these three has the most complex framing and which the most state?
2. What could you generalize across all your dissectors, and what should stay protocol-specific?
3. At what point does a macro or code generator pay for itself?

## Parts
### Part 1
For each protocol: notes, fixtures, parser, fuzz target, differential test, registry entry, ADRs for decisions.

### Part 2
S7comm (ISO-on-TCP/TPKT/COTP then S7 PDU with job/ack-data pairing).

### Part 3
IEC 60870-5-104 (APCI frames, U/I/S formats, ASDU with information objects and type IDs).

### Part 4
OPC UA binary (secure channel, message chunks, built-in types); scope carefully and record what you leave out.

### Part 5
Refactor shared helpers (TPKT/COTP, TLV iterators) into common crates only after the second use.

## Exercises
1. Track your time per protocol; target a falling curve and identify why.
2. Write the 'new protocol checklist' in the framework docs from your experience.
3. (stretch) Try `winnow` or `binrw` for one protocol and compare readability and speed with your hand-written parser.

## Exit criteria
- [ ] Three new dissectors with the full quality bar (unit, property, fuzz, differential)
- [ ] Checklist-driven workflow doc
- [ ] Shared code extracted with justification
- [ ] Benchmarks show no pathological regressions in the combined pipeline
- [ ] `just check` green; MEMORY.md updated; `git tag S22`

## Teach-back
Explain how your process improved from the first protocol to the third, with evidence.

## Rust lens (summary)
declarative macros (`macro_rules!`) in moderation, generic helpers, `winnow`/`nom`/`binrw` comparison, API consistency across crates.

## Capstone state after this tutorial
S22: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
IEC 60870-5-104 overview; Siemens S7 community docs; OPC UA Part 6 (mappings) overview.
