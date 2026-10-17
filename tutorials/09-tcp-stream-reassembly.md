# 09. TCP stream reassembly

Phase: 3 | Time: ~12 h | Capstone: S8 -> S9
Prerequisites: tutorial 08; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Turn out-of-order, retransmitted, overlapping TCP segments into an ordered byte stream per direction, with strictly bounded memory and tolerance for mid-stream starts and gaps.

## Predict first
1. Why is TCP a byte stream and not a message stream, and what does that mean for parsers?
2. What should the reassembler do when two overlapping segments carry different bytes?
3. If a capture starts mid-connection, what is the initial sequence number, and how do you cope?

## Parts
### Part 1
Sequence-number arithmetic with wraparound (`u32` modular comparison).

### Part 2
Per-direction buffers: in-order delivery, out-of-order segments in a `BTreeMap`, duplicate and overlap policy (record an ADR).

### Part 3
Gap handling: timeouts or max-gap thresholds, 'lost data' markers so dissectors can resync.

### Part 4
Memory bounds: per-flow and global caps, eviction policy.

### Part 5
API: `feed(segment) -> events` where events are `Data`, `Gap`, `Closed`; plug into the Modbus dissector.

## Exercises
1. Property test: shuffle and duplicate segments of a known stream; the output must equal the original.
2. Simulate an attacker sending 100k tiny out-of-order segments; show memory stays under the cap.
3. (stretch) Handle RST and FIN states and half-closed connections.

## Exit criteria
- [ ] Reassembly output matches `tshark -z follow,tcp` on real captures
- [ ] Wraparound, overlap, retransmission, and midstream tests pass
- [ ] Memory bounded under adversarial input (test and measure)
- [ ] ADR: overlap policy and gap policy
- [ ] `just check` green; MEMORY.md updated; `git tag S9`

## Teach-back
Explain how an attacker can exploit different overlap policies between your reassembler and the target host, and what you chose and why.

## Rust lens (summary)
`BTreeMap` range queries, modular arithmetic with `wrapping_*`, state encapsulation, avoiding copies (`Bytes` or slice ranges), API design for event-style output.

## Capstone state after this tutorial
S9: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
RFC 9293; 'Insertion, Evasion, and Denial of Service' (Ptacek and Newsham); Suricata/Zeek reassembly docs.
