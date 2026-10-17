# 03. Traits, generics, lifetimes: Ethernet and IPv4

Phase: 1 | Time: ~10 h | Capstone: S2 -> S3
Prerequisites: tutorial 02; Rust Book ch. 10
Status: full

## Goal
Parse real network headers with zero-copy structs: Ethernet II (with a single
VLAN tag) and IPv4. Introduce a `Parse` trait so every layer looks the same.
This is where lifetimes stop being scary.

## Predict first
1. Given `struct Header<'a> { payload: &'a [u8] }`, what stops you from returning
   a `Header` that outlives the buffer it was parsed from?
2. IPv4's IHL field is 4 bits and counts 32-bit words. If IHL = 5, how many bytes is the header? Which IHL values are invalid?
3. An IPv4 total-length field says 40 but the Ethernet frame has 60 bytes (padding). Which one tells you where the IP payload ends?
4. Is `trait Parse { fn parse(r: &mut Reader) -> Result<Self>; }` valid without a lifetime on the trait? Why or why not?

## Parts

### Part 1: Know the wire format (protocol notes first)
Create `protocol-notes/ethernet-ipv4.md` from the template. Fill in, using
your Wireshark observations from tutorial 00 and public references:

Ethernet II: dst MAC (6), src MAC (6), EtherType (2). If EtherType is 0x8100
(802.1Q): TCI (2) then the *inner* EtherType (2). Payload follows.

IPv4 (20-60 bytes): version (4 bits) + IHL (4 bits), DSCP/ECN, total length (2),
identification (2), flags (3 bits) + fragment offset (13 bits), TTL, protocol,
header checksum (2), src (4), dst (4), options (IHL*4 - 20 bytes).

Write down the invalid conditions you will reject: version != 4, IHL < 5,
total length < IHL*4, header longer than available bytes.

### Part 2: The `Parse` trait and lifetimes
```rust
pub trait Parse<'a>: Sized {
    fn parse(r: &mut Reader<'a>) -> Result<Self>;
}
```
The lifetime lives on the trait because implementations return values that
borrow from the same buffer as the reader. Read it as: "a type that can be
parsed from a reader over bytes of lifetime `'a`, and may borrow from them."

Rust lens: lifetime elision rules explain why you rarely write `'a` on plain
functions but must on structs and traits that hold references. Learn the three
rules; they predict most compile errors.

### Part 3: Ethernet II (test first)
```rust
pub struct MacAddr(pub [u8; 6]);          // Display as aa:bb:cc:dd:ee:ff

pub struct Ethernet<'a> {
    pub dst: MacAddr,
    pub src: MacAddr,
    pub vlan: Option<u16>,               // VLAN id if tagged (12 bits)
    pub ether_type: EtherType,
    pub payload: &'a [u8],
}
```
Tests (build packets with byte arrays):
- untagged IPv4 frame parses, payload is the remaining bytes
- single 802.1Q tag: `vlan == Some(id)` and the inner EtherType is reported
- 13-byte input returns `Incomplete { needed: 1 }`
- unknown EtherType round-trips as `Unknown(x)`; it is not an error

Design question for your notes: if a QinQ (double tag) frame appears, should the
parser return `Unsupported`, loop over tags, or report the outer tag only?
Pick one, record it as ADR-0003, and test it.

Rust lens: implement `Parse<'a> for Ethernet<'a>`. Notice the lifetime
appears twice, and that `payload: &'a [u8]` comes from `r.rest()` or `take`.
Implement `Display` for `MacAddr` using `{:02x}`.

### Part 4: IPv4 (test first)
```rust
pub struct Ipv4<'a> {
    pub ihl_words: u8,
    pub total_len: u16,
    pub identification: u16,
    pub dont_fragment: bool,
    pub more_fragments: bool,
    pub fragment_offset: u16,            // in 8-byte units
    pub ttl: u8,
    pub protocol: IpProtocol,            // Tcp, Udp, Icmp, Unknown(u8)
    pub checksum: u16,
    pub src: std::net::Ipv4Addr,
    pub dst: std::net::Ipv4Addr,
    pub options: &'a [u8],
    pub payload: &'a [u8],
}
```
Required behavior:
- reject version != 4, IHL < 5 as `Malformed`
- `total_len` bounds the payload: payload length is `total_len - IHL*4`, **not** "rest of the frame" (this handles Ethernet padding)
- if the buffer is shorter than `total_len`, return `Incomplete` (or a "truncated capture" variant; decide and record in the ADR from Part 3; captures are often snap-length truncated)
- compute and expose `checksum_valid()` (ones'-complement sum over the header); do not reject packets with bad checksums in the parser, since NIC offload makes captured checksums unreliable; let the caller decide
- fragments (`more_fragments` or offset > 0): parse the header, but mark payload as a fragment; do not try to reassemble yet

Hints (escalating):
1. Read the first byte, then `let version = b >> 4; let ihl = b & 0x0f;`.
2. Use `usize::from(ihl) * 4`, not `ihl as usize * 4`, and check `>= 20` first.
3. Use `r.sub_reader(...)` or `take` to carve the options and payload; never index.
4. Checksum: sum big-endian 16-bit words into a `u32`, fold carries, bitwise NOT; a valid header sums to `0xffff` before NOT.

Rust lens: bit extraction with shifts and masks; `usize::from(u8)` (lossless)
vs. `as` (may truncate); `Ipv4Addr::from([a, b, c, d])`; iterators with
`chunks_exact(2)` for the checksum.

### Part 5: Layer chaining
Write `fn parse_frame(bytes: &[u8]) -> Result<Frame<'_>>` that dissects
Ethernet then, if IPv4, IPv4, and returns a struct holding both layers. Notice
the elided lifetime in `Frame<'_>`: every borrowed field comes from `bytes`.

Update `wg inspect <file>` to take a *raw hex string* or a file containing a
single Ethernet frame and print the layers. (In tutorial 05 it reads pcap files.)

### Part 6: Cross-check against tshark
Export one frame from your Modbus capture as raw bytes:
```bash
tshark -r captures/modbus.pcap -c 1 -x          # copy the hex
```
Feed the same frame to `wg inspect` and compare MACs, VLAN, IPs, TTL,
protocol, and lengths with `tshark -V`. Any mismatch is your bug until
proven otherwise. This differential habit becomes formal in tutorial 08.

## Exercises
1. (core) Add `Ipv4::header_len()` and `payload_len()`; add property-style checks with a loop over all IHL values 0-15.
2. (core) Add `ARP` as a second EtherType handler returning `Unsupported("arp")` through `parse_frame`; confirm unsupported does not abort a capture-wide loop (you will use this in tutorial 05).
3. (core) Write a doc test on `Ethernet::parse` showing correct usage.
4. (stretch) Implement `Parse` for IPv6 fixed header only (40 bytes); skip extension headers for now.
5. (stretch) Make `parse_frame` generic over a `Layer` trait with an associated `Next` type. Is it better than the plain function? Record your opinion.

## Exit criteria
- [ ] `Ethernet`, `Ipv4`, `parse_frame` with tests: truncation, padding, VLAN, options, bad IHL, unknown types
- [ ] `just check` green; no panics possible by construction (no indexing/unwrap in non-test code)
- [ ] You matched `wg inspect` output with tshark on at least 3 real frames
- [ ] You can explain `impl<'a> Parse<'a> for Ipv4<'a>` line by line
- [ ] ADR-0003 (VLAN/QinQ) and ADR-0004 (truncation semantics) written
- [ ] `protocol-notes/ethernet-ipv4.md` finished
- [ ] `git tag S3`

## Teach-back
Explain, without code, how a `Frame<'a>` returned from `parse_frame` stays
valid, what the borrow checker prevents, and why copying the payload into a
`Vec` would be a design smell here (and one case where you would still do it).

## Rust lens (summary)
Traits with lifetime parameters, structs that borrow, elision, bit
manipulation, lossless conversion, doc tests, and why parsers are the
canonical showcase of Rust's borrow checker.

## Capstone state after this tutorial
S3: `wg-core` parses Ethernet II (+VLAN) and IPv4 with a `Parse` trait;
`wg inspect` shows layers for a single frame.

## Further reading
Rust Book ch. 10.3 (lifetimes). Rust Reference: lifetime elision.
RFC 791 (IPv4); IEEE 802.3 / 802.1Q overviews.
