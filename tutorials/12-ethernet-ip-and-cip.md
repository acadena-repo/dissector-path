# 12. EtherNet/IP and CIP

Phase: 3 | Time: ~14 h | Capstone: S11 -> S12
Prerequisites: tutorial 11; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Dissect a nested industrial protocol: the EtherNet/IP encapsulation, common packet format, and CIP services/paths, including connected and unconnected messaging.

## Predict first
1. How many layers does a typical CIP read-tag request traverse on the wire?
2. What is a CIP path and why is it tricky to parse safely?
3. Which messages are UDP (implicit I/O) vs. TCP (explicit)?

## Parts
### Part 1
Notes: encapsulation header (24 bytes), commands (ListIdentity, RegisterSession, SendRRData, SendUnitData), common packet format items.

### Part 2
CIP service codes, class/instance/attribute paths, segment types, data types.

### Part 3
Session tracking (session handle) and connected-message state (connection IDs).

### Part 4
Identity extraction from ListIdentity (vendor, device type, product, revision) for asset inventory.

### Part 5
Anomaly and risk tagging: tag writes, firmware services, reset service.

## Exercises
1. Decode a Logix-style tag read request/response using your path parser.
2. Property test: path parser never loops or overreads on random segments.
3. (stretch) Handle multiple-service packets.

## Exit criteria
- [ ] Extracts device identity from a real capture and matches tshark
- [ ] Nested layer parsing bounded by outer lengths (tests for lying inner lengths)
- [ ] Registry integration with detection on TCP/UDP 44818 and 2222
- [ ] Protocol notes and ADRs completed
- [ ] `just check` green; MEMORY.md updated; `git tag S12`

## Teach-back
Explain how outer length fields constrain inner parsing and what bug appears if you trust the inner length.

## Rust lens (summary)
nested borrowed structs, `Cow<'a, [u8]>` where ownership is conditional, iterator-based segment decoding, macro-free code reuse.

## Capstone state after this tutorial
S12: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
ODVA public overviews, Wireshark ENIP/CIP dissector source.
