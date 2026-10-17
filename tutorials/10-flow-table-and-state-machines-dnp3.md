# 10. Flow table and state machines (DNP3)

Phase: 3 | Time: ~14 h | Capstone: S9 -> S10
Prerequisites: tutorial 09; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Track flows by 5-tuple and implement a stateful, multi-layer protocol: DNP3 link layer frames with CRCs, transport-layer fragments, and application-layer request/response correlation.

## Predict first
1. Why does DNP3 insert CRCs every 16 data bytes and what does that do to a zero-copy design?
2. How do you correlate a response with its request, and what if the response never comes?
3. What should a flow table do when it is full?

## Parts
### Part 1
`wg-flow`: flow key (canonicalized 5-tuple), flow state, timeouts, eviction.

### Part 2
DNP3 notes: link header, user data blocks with CRC-16, transport header (FIR/FIN/SEQ), application control, function codes, object headers.

### Part 3
Decoder as an explicit state machine (enum states) driven by reassembled stream events.

### Part 4
Fragment reassembly across transport segments with bounds.

### Part 5
Outputs: function code, objects, is_control (select/operate/direct operate), anomalies.

## Exercises
1. Verify CRCs and expose failures as data, not errors.
2. Property test: random byte soup into the DNP3 state machine never panics and always makes progress.
3. (stretch) Handle unsolicited responses and confirm messages.

## Exit criteria
- [ ] Decodes a real DNP3 capture consistent with tshark
- [ ] CRC-aware parsing without copying more than necessary (document where you copy and why)
- [ ] Flow table has bounded memory with an eviction policy and tests
- [ ] State machine diagram in the notes; ADR on state representation
- [ ] `just check` green; MEMORY.md updated; `git tag S10`

## Teach-back
Walk through a DNP3 read request and response through all three layers and the state each layer keeps.

## Rust lens (summary)
state machines as enums, `HashMap` entry API, `Option<Box<T>>`-free designs, `mem::take`/`replace`, newtype IDs, handling partial progress without cloning.

## Capstone state after this tutorial
S10: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
IEEE 1815 (DNP3) overview, public DNP3 primers, Wireshark DNP3 dissector.
