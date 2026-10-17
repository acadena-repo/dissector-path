# 02. Types and error modeling: the Reader

Phase: 1 | Time: ~8 h | Capstone: S1 -> S2
Prerequisites: tutorial 01; Rust Book ch. 5-6, 9
Status: full

## Goal
Build the single most important primitive of every dissector: a bounds-checked
`Reader` over `&[u8]` that returns a typed `ParseError` instead of ever
panicking. You will learn structs, enums, `Option`/`Result`, the `?` operator,
integer semantics, and newtypes.

## Predict first
1. `u16::from_be_bytes([0x01, 0x02])`: what value? And with `from_le_bytes`?
2. What does `250u8 + 10` do in a debug build? In a release build? What does `250u8.checked_add(10)` return?
3. If a header says "payload length = 65535" and you have 12 bytes left, which
   error is it: `Incomplete`, `Malformed`, or neither? Does it depend on whether this is a TCP stream or a UDP datagram?
4. Why is `enum Function { Read, Write, Unknown(u8) }` better than `enum Function { Read, Write }` plus a panic on other values?

## Parts

### Part 1: The error type (design before code)
Three outcomes matter for dissection:

| Variant | Meaning | Caller reaction |
|---|---|---|
| `Incomplete { needed }` | valid so far, need N more bytes | TCP: buffer and wait. UDP: drop or log truncation |
| `Malformed(&'static str)` | structurally invalid | log, drop, maybe resync |
| `Unsupported(&'static str)` | valid but not decoded by us | count it, skip using the length |

Write it by hand first, so you understand what `thiserror` generates later:

```rust
use std::fmt;

#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub enum ParseError {
    Incomplete { needed: usize },
    Malformed(&'static str),
    Unsupported(&'static str),
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ParseError::Incomplete { needed } => write!(f, "incomplete: need {needed} more byte(s)"),
            ParseError::Malformed(why) => write!(f, "malformed: {why}"),
            ParseError::Unsupported(what) => write!(f, "unsupported: {what}"),
        }
    }
}

impl std::error::Error for ParseError {}

pub type Result<T> = std::result::Result<T, ParseError>;
```
Put it in `crates/wg-core/src/error.rs`. Discuss with yourself: why
`&'static str` and not `String`? (Allocation-free, cheap to construct on hot
error paths; cost: no dynamic details. When would you want a richer error?
Write that as ADR-0002.)

Rust lens: `#[non_exhaustive]` lets you add variants later without breaking
downstream `match`es. `thiserror` derives `Display` and `Error` for you; adopt
it after you have written this by hand once (add `thiserror = "1"` to
`wg-core/Cargo.toml`; check the current major version).

### Part 2: The Reader (tests first)
Create `crates/wg-core/src/reader.rs`:

```rust
pub struct Reader<'a> {
    buf: &'a [u8],
}
```
Why a lifetime `'a`? The Reader *borrows* the packet bytes; it must not outlive
them. Read the struct definition aloud: "a Reader that borrows bytes living
for `'a`."

Required API (all return `Result<_>`; none may panic):

| Method | Behavior |
|---|---|
| `new(buf: &'a [u8]) -> Self` | wrap bytes |
| `remaining(&self) -> usize` | bytes left |
| `is_empty(&self) -> bool` | no bytes left |
| `peek(&self, n: usize) -> Result<&'a [u8]>` | look, don't consume |
| `take(&mut self, n: usize) -> Result<&'a [u8]>` | consume n bytes, return a slice |
| `skip(&mut self, n: usize) -> Result<()>` | consume and discard |
| `u8`, `u16_be`, `u16_le`, `u32_be`, `u32_le` | read integers |
| `rest(self) -> &'a [u8]` | the unconsumed remainder |

Notice the return type of `take`: `&'a [u8]`, not `&'_ [u8]`. The returned slice
borrows from the *original buffer*, not from the Reader. This lets you keep
parsed fields alive after the Reader moves on. This is the key lifetime idea in
zero-copy parsing; make sure you can explain it.

Behavior to pin with tests:
- `take(n)` with fewer than `n` bytes left returns `Incomplete { needed: n - remaining }` and does **not** consume anything
- reads advance the position exactly by the number of bytes read
- `u16_be` on `[0x01, 0x02]` is `0x0102`; `u16_le` is `0x0201`
- `take(0)` succeeds and returns an empty slice

Hints (escalating):
1. Implement `take` with `self.buf.split_at_checked(n)`; on `None` compute `needed` with `n.saturating_sub(self.buf.len())`.
2. Implement integer reads on top of `take`, then convert with `try_into()` to a fixed-size array and `u16::from_be_bytes`. The conversion cannot fail after `take(2)`, but do not `unwrap`: map the (impossible) error to `ParseError::Malformed("internal: length mismatch")`.
3. Make a private helper `fn array<const N: usize>(&mut self) -> Result<[u8; N]>` (const generics) and build all integer reads from it.

Rust lens: `&mut self` methods that advance state; `Self` in signatures; const
generics (`[u8; N]`); `saturating_sub`. Notice how `?` makes each integer read
a one-liner.

### Part 3: Newtypes and enums for meaning
A `u16` can be a port, a length, a transaction id, or an EtherType. Mixing them
is a classic bug. Create small types in `wg-core/src/types.rs`:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Port(pub u16);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EtherType {
    Ipv4,
    Arp,
    Vlan,
    Ipv6,
    Unknown(u16),
}

impl From<u16> for EtherType {
    fn from(v: u16) -> Self {
        match v {
            0x0800 => EtherType::Ipv4,
            0x0806 => EtherType::Arp,
            0x8100 => EtherType::Vlan,
            0x86dd => EtherType::Ipv6,
            other => EtherType::Unknown(other),
        }
    }
}
```
Add the reverse `From<EtherType> for u16` and a test that
`u16::from(EtherType::from(x)) == x` for a handful of values including an
unknown one. (Tutorial 04 turns this into a property test over all 65,536 values.)

Rust lens: `#[derive]` for `Debug, Clone, Copy, PartialEq, Eq, Hash`; newtype
pattern; `From`/`Into`; `Unknown(x)` keeps round-tripping lossless.

### Part 4: Make the CLI use `ParseError`
Add `wg inspect <file>` that prints the first 14 bytes as Ethernet II
(dst MAC, src MAC, EtherType) *only if the file is raw Ethernet*; for now,
feed it a hand-made 14-byte file. Show `Incomplete` on a shorter file.
(Tutorial 03 does this properly with a parser; here you are just wiring the
`Reader` and error display into a binary.)

## Exercises
1. (core) Add `u24_be` (used by some protocols) and test it.
2. (core) Add `Reader::sub_reader(&mut self, n: usize) -> Result<Reader<'a>>` that carves out the next `n` bytes as an independent reader. Why is this crucial for length-prefixed messages?
3. (core) Write a test proving a failed `take` leaves the position unchanged.
4. (stretch) Add `Reader::u16_be_checked_len(max: usize)` that reads a length and returns `Malformed` if it exceeds `max`. Bounding every wire-declared length is rule 4 in RUST-TRACK.md.
5. (stretch) Replace your manual `Display`/`Error` impls with `thiserror` and compare the code. What did you gain, what did you lose?

## Exit criteria
- [ ] `ParseError`, `Reader`, `Port`, `EtherType` implemented with tests; `just check` green
- [ ] There is no `unwrap`, `expect`, or indexing in non-test code
- [ ] You can explain why `take` returns `&'a [u8]` (not tied to `&mut self`)
- [ ] You can state the difference between `Incomplete` and `Malformed` and give one TCP and one UDP example
- [ ] ADR-0002 (error representation: `&'static str` vs. richer errors) is written
- [ ] `git tag S2`

## Teach-back
Explain what would go wrong if `take` returned a slice tied to `&mut self`
instead of `'a`, and show the compile error you would get when trying to hold
two fields at once.

## Rust lens (summary)
Structs with lifetimes, enums with data, `Option`/`Result`, `?`, `From`,
`#[derive]`, `#[non_exhaustive]`, newtypes, const generics, integer conversion
and checked/saturating arithmetic.

## Capstone state after this tutorial
S2: `wg-core` has `error`, `reader`, `types`, `hexdump`; the CLI has `inspect`.

## Further reading
Rust Book ch. 6 (enums), ch. 9 (errors), ch. 10 (generics, lifetimes intro).
`std::error::Error`, `thiserror` docs, API Guidelines on error types.
