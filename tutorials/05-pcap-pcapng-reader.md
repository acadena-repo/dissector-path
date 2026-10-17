# 05. pcap/pcapng reader

Phase: 2 | Time: ~8 h | Capstone: S4 -> S5
Prerequisites: tutorial 04; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Read classic pcap and pcapng files from scratch, yielding packets lazily with timestamps and link types, so Wireglass can run on real captures.

## Predict first
1. Why does the pcap magic number tell you the byte order and timestamp precision of the file?
2. What is a snap length, and how does it show up in a packet record (captured vs. original length)?
3. Should a reader return a `Vec<Packet>` or an iterator? What does each cost for a 4 GB file?

## Parts
### Part 1
Binary format study: pcap global/record headers, pcapng blocks (SHB, IDB, EPB); write protocol notes.

### Part 2
Reader over `std::io::Read` with a buffer; yield `Packet<'a>` borrowing the buffer (a lending-iterator problem: discuss the trade-off and choose).

### Part 3
Link-type dispatch (Ethernet, Linux cooked SLL); wire into `parse_frame`.

### Part 4
Error handling: truncated files, bad magic, unsupported block types (skip using the length).

### Part 5
`wg dissect <file>` prints one summary line per packet.

## Exercises
1. Add timestamp conversion to `std::time::SystemTime`; handle micro vs. nanosecond files.
2. Count packets per EtherType across a capture and compare with `tshark -z io,phs`.
3. (stretch) Support byte-swapped pcap files and a pcapng file with multiple interfaces.

## Exit criteria
- [ ] Reads pcap and pcapng files from your corpus identically to tshark's packet count
- [ ] Memory stays flat on a large file (measure RSS)
- [ ] Truncated/corrupt files produce errors, never panics (property test over mutated headers)
- [ ] ADR: owned vs. borrowed packets (and the iterator design)
- [ ] `just check` green; MEMORY.md updated; `git tag S5`

## Teach-back
Explain why `Iterator` cannot yield items that borrow from the iterator itself, and what you did instead.

## Rust lens (summary)
`io::Read`, `BufReader`, custom iterators, modules and crates split (`wg-pcap`), lending-iterator workaround, `Cow`, `std::time`.

## Capstone state after this tutorial
S5: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
pcap-savefile man page; pcapng spec (IETF draft); `pcap-parser` source.
