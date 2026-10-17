# 06. Layered parsing: VLAN, IPv6, UDP, TCP

Phase: 2 | Time: ~10 h | Capstone: S5 -> S6
Prerequisites: tutorial 05; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Complete the L2-L4 stack: stacked VLANs, IPv6 with extension headers, UDP, and TCP with options, producing a typed view of every packet in a capture.

## Predict first
1. How do IPv6 extension headers chain, and why can they make parsing unbounded if you are careless?
2. TCP header length is in 32-bit words: what are the valid values and what are the options?
3. Which layer owns the 'where does the payload end' decision, and what happens with Ethernet padding?

## Parts
### Part 1
Move network parsers to `wg-net`; define a `Packet<'a>` with optional layers.

### Part 2
IPv6: fixed header, extension-header walk with a hard cap on header count and total length.

### Part 3
UDP and TCP: ports, flags, seq/ack, window, options (MSS, window scale, SACK, timestamps) as an iterator over borrowed option bytes.

### Part 4
IPv4 fragmentation: detect and expose; defer reassembly (record an ADR).

### Part 5
Checksums with pseudo-headers; expose validity but never reject on it.

## Exercises
1. Property: arbitrary bytes never panic for every layer parser.
2. Cross-check 100 packets from a capture against `tshark -T fields` output in a script.
3. (stretch) ICMP and ARP minimal parsers returning structured data.

## Exit criteria
- [ ] L2-L4 stack parses all packets in two public captures without panic
- [ ] Hostile-input tests: infinite extension-header chains, zero-length options, oversize lengths
- [ ] Differential check vs. tshark on ports, flags, seq numbers
- [ ] ADR: fragmentation strategy
- [ ] `just check` green; MEMORY.md updated; `git tag S6`

## Teach-back
Walk through how a hostile IPv6 packet could cause unbounded work in a naive parser and which cap prevents it.

## Rust lens (summary)
enum dispatch, composition of borrowed layers, iterators over option bytes, `const` limits, `u16::try_from`, `#[repr]` awareness (and why not to cast structs).

## Capstone state after this tutorial
S6: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
RFC 8200 (IPv6), RFC 9293 (TCP), RFC 768 (UDP).
