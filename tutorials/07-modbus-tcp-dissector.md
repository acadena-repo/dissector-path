# 07. Modbus/TCP dissector

Phase: 2 | Time: ~12 h | Capstone: S6 -> S7
Prerequisites: tutorial 06; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Ship your first real ICS dissector: Modbus/TCP with MBAP framing, function-code decoding for requests and responses, exception responses, and risk classification (read vs. write).

## Predict first
1. How does Modbus/TCP delimit messages on a byte stream, and what happens when two ADUs arrive in one segment?
2. What is the max ADU size, and what should the parser do with a declared length beyond it?
3. Why is an exception response not an error from the parser's point of view?

## Parts
### Part 1
Write `protocol-notes/modbus.md` from the spec: MBAP header, PDU, function codes (1-6, 15, 16, 22, 23, 43/14), exceptions.

### Part 2
`wg-proto-modbus` crate: `parse_adu(&[u8]) -> Result<(Adu<'_>, &[u8])>` returning the remainder.

### Part 3
Request/response decoding into typed enums with `Unknown` function codes preserved.

### Part 4
Direction handling: which side is client or server decides how the PDU is interpreted (the same bytes mean different things).

### Part 5
Risk classification and a structured output record (function, address range, quantity, is_write).

## Exercises
1. Decode Read Holding Registers and Write Multiple Registers fully, request and response.
2. Handle pipelined ADUs in one buffer with a loop; guarantee progress (no zero-length infinite loops).
3. (stretch) Report out-of-range quantity/address combinations as anomalies without rejecting the message.

## Exit criteria
- [ ] Matches tshark's Modbus fields on a real capture (script included)
- [ ] Unit, table, property tests; incomplete vs. malformed vs. unsupported all exercised
- [ ] Pipelined messages and truncated tails handled
- [ ] `wg dissect` prints Modbus summaries; notes file complete
- [ ] ADR: how protocol-level semantic anomalies are reported
- [ ] `just check` green; MEMORY.md updated; `git tag S7`

## Teach-back
Explain why returning the remainder is the right parse signature, and how it composes with TCP reassembly later.

## Rust lens (summary)
incremental parsing, enums with payloads, `Unknown` variants, `impl From`, crate boundaries, API docs and doc tests.

## Capstone state after this tutorial
S7: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
Modbus Application Protocol spec and Modbus over TCP/IP implementation guide.
