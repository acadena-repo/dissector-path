# 16. Linux capture: AF_PACKET and ring buffers

Phase: 4 | Time: ~14 h | Capstone: S15 -> S16
Prerequisites: tutorial 15; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Capture live traffic on Linux with raw sockets and memory-mapped rings, understand drops and offloads, and wrap the unsafe system interface behind a small safe API.

## Predict first
1. What is the difference between libpcap and raw `AF_PACKET` sockets in terms of copies and syscalls?
2. What do GRO/LRO and checksum offload do to what you capture?
3. How do you know you are losing packets, and where is the counter?

## Parts
### Part 1
Lab setup: veth pairs or a dummy interface with `tcpreplay` to generate known traffic safely.

### Part 2
Basic `AF_PACKET` socket via `socket2`/`libc`/`nix`; `epoll`; reading frames.

### Part 3
TPACKET_V3 mmap ring: block layout, frame headers, ownership of blocks; design the safe wrapper (needs a scoped, justified `unsafe`).

### Part 4
Kernel counters: `PACKET_STATISTICS`, `/proc/net/dev`, `ethtool -S`; offload settings with `ethtool -k`.

### Part 5
Integrate as a capture source behind the same trait as the pcap reader.

## Exercises
1. Replay a capture at 10x speed and measure drops with the socket path vs. libpcap.
2. Disable GRO and compare observed packet sizes.
3. (stretch) Sketch an eBPF/XDP filter plan with `aya` and decide whether it is worth it.

## Exit criteria
- [ ] Live capture runs on a lab interface and feeds the pipeline
- [ ] Drop accounting is visible and verified against a known replay
- [ ] Unsafe code isolated in one module/crate with a safety-contract doc comment for every `unsafe` block
- [ ] You can explain ring buffer ownership and how the kernel and your process share it
- [ ] `just check` green; MEMORY.md updated; `git tag S16`

## Teach-back
Explain the safety contract of your ring wrapper: what invariants make each unsafe block sound?

## Rust lens (summary)
`unsafe` with documented invariants, `libc`/`nix`, `OwnedFd`, RAII wrappers, `mmap` lifetimes, error mapping from `errno`, feature-gating Linux-only code.

## Capstone state after this tutorial
S16: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
`man 7 packet`, kernel docs on packet_mmap, `socket2`, `nix`, `aya` book.
