# 01. Ownership, borrowing, slices: hexdump

Phase: 1 | Time: ~6 h | Capstone: S0 -> S1
Prerequisites: tutorial 00; Rust Book chapters 3-4 (read alongside)
Status: full

## Goal
Build `wg hexdump <file>`: a function that renders bytes as an offset column,
hex bytes, and an ASCII gutter, like `xxd`. You will learn ownership, borrowing,
and slices, the three ideas that make zero-copy parsing possible.

## Predict first
1. What does this print, and does it compile?
   ```rust
   let a = String::from("modbus");
   let b = a;
   println!("{a} {b}");
   ```
2. A function takes `data: &[u8]`. Can the caller still use the original `Vec<u8>` afterwards? Why?
3. What is the difference between `Vec<u8>`, `[u8; 4]`, and `&[u8]`? Which one is a *view*?
4. `bytes[3]` on a 2-byte slice: compile error, panic, or `None`?
5. Why does `data.chunks(16)` not need to copy anything?

## Parts

### Part 1: Ownership in five minutes
Every value has exactly one owner. Assignment *moves* ownership (for types
that are not `Copy`). When the owner goes out of scope, the value is dropped.
Integers and other small types are `Copy`: assignment duplicates them.

Experiment: write small functions that take `Vec<u8>` by value, then by `&Vec<u8>`,
then by `&[u8]`. Observe when the caller loses access. Conclusion to write in
your notes: *a dissector receives the packet buffer as `&[u8]` and never owns it.*

Rust lens: parameters take `&[u8]`, not `&Vec<u8>`, because a slice accepts
vectors, arrays, and sub-ranges. Clippy's `ptr_arg` lint enforces this.

### Part 2: Borrowing rules
Any number of shared borrows (`&T`) or exactly one mutable borrow (`&mut T`),
never both at once. The compiler checks this at compile time, which is why
Rust has no data races in safe code.

Experiment: try to hold `let first = &v[0];` and then `v.push(1);` before
using `first`. Read the error. Explain why `push` might invalidate `first`
(hint: reallocation).

### Part 3: Slices are views
A slice `&[u8]` is a pointer plus a length. `&data[2..6]` creates a new view
without copying. Parsers peel headers off a buffer by narrowing the view:
`let (header, rest) = data.split_at(8);` (panics if too short) vs.
`data.get(..8)` (returns `Option`).

Experiment: write `fn first_n(data: &[u8], n: usize) -> Option<&[u8]>` using
`get`. Test with exact length, too short, and `n = 0`.

Rust lens: prefer `get`, `split_first`, `split_at_checked`, `first_chunk`
(check your Rust version) over indexing when the input is untrusted.

### Part 4: Implement `hexdump` (test first)
Create `crates/wg-core/src/hexdump.rs` and expose it in `lib.rs`
(`pub mod hexdump;`). Signature:

```rust
pub fn hexdump(data: &[u8]) -> String
```

Required format (16 bytes per line):
```
00000000  48 65 6c 6c 6f 2c 20 6d  6f 64 62 75 73 21 00 ff  |Hello, modbus!..|
00000010  0a                                                |.|
```
Rules: 8-hex-digit offset, two spaces, bytes in lowercase hex separated by a
space with an extra space after the 8th, padding so the gutter aligns on the
last partial line, `|`-delimited ASCII with `.` for non-printable bytes.
Empty input returns an empty string.

Write these tests first in the same file:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_input_gives_empty_output() {
        assert_eq!(hexdump(&[]), "");
    }

    #[test]
    fn one_full_line() {
        let out = hexdump(b"Hello, modbus!\x00\xff");
        assert!(out.starts_with("00000000  48 65 6c 6c 6f 2c 20 6d  6f 64 62 75 73 21 00 ff"));
        assert!(out.ends_with("|Hello, modbus!..|\n"));
    }

    #[test]
    fn partial_line_keeps_gutter_aligned() {
        let out = hexdump(&[0x0a]);
        let full = hexdump(&[0u8; 16]);
        // the '|' of the gutter must be at the same column in both
        assert_eq!(out.find('|'), full.find('|'));
    }

    #[test]
    fn second_line_offset_is_0x10() {
        let out = hexdump(&[0u8; 17]);
        assert_eq!(out.lines().nth(1).map(|l| &l[..8]), Some("00000010"));
    }
}
```
Hints, in escalating order (try each only after a real attempt):
1. Iterate with `data.chunks(16).enumerate()`; the line offset is `i * 16`.
2. Build output in a `String`; use `std::fmt::Write` and `write!(out, ...)`
   (it returns a `Result`; for writes to a `String` it cannot fail, but do not
   `unwrap`: use `let _ = write!(...)` and say why in a comment, or handle with `?`
   in an inner function returning `fmt::Result`).
3. For ASCII: `byte.is_ascii_graphic() || byte == b' '` then `byte as char`,
   else `'.'`.

Rust lens: `for (i, chunk) in data.chunks(16).enumerate()` is idiomatic;
avoid manual index counters. `as char` on a `u8` is safe and lossless; `as`
casts on *wider* types can truncate, so know the difference.

### Part 5: The CLI
Update `wg-cli/src/main.rs`:
- read the first argument as a path (`std::env::args().nth(1)`)
- `std::fs::read(path)` returns `io::Result<Vec<u8>>`
- print `wg_core::hexdump::hexdump(&bytes)`; note `&bytes` borrows the `Vec`
  as a slice (deref coercion)
- on error, print to stderr and exit with code 1 (`std::process::exit(1)`)

Rust lens: in `main`, use a small `fn run() -> Result<(), Box<dyn Error>>` and
`?`, then handle the error once in `main`. This keeps error handling out of
your logic. (In tutorial 02 you replace `Box<dyn Error>` with a typed error.)

### Part 6: Compare with the reference
```bash
cargo run -p wg-cli -- captures/modbus.pcap | head -5
xxd captures/modbus.pcap | head -5
```
Differences in format are fine; the bytes must match. Take one pcap global
header (first 24 bytes) and identify the magic number (`d4 c3 b2 a1` or
`a1 b2 c3 d4`). Why does it tell you the endianness of the file? (Tutorial 05
builds on this.)

## Exercises
1. (core) Add a `--width N` option (default 16). What changes in the tests?
2. (core) Write `fn count_non_ascii(data: &[u8]) -> usize` using iterator adapters (no `for` loop).
3. (core) Explain, in a code comment, why `hexdump` takes `&[u8]` and returns `String` (owned). Who owns what?
4. (stretch) Make `hexdump` return an iterator of lines instead of one `String`. What lifetime issues appear?
5. (stretch) Run `hexdump` on a 100 MB file and watch memory. Where does it allocate? Do not optimize yet; write the observation in your notes (tutorial 13 returns to it).

## Exit criteria
- [ ] All four tests plus your own pass; `just check` green
- [ ] No `unwrap`, `expect`, or indexing in non-test code (clippy confirms)
- [ ] You can explain move vs. borrow vs. copy with a code example, unprompted
- [ ] You can explain why `&[u8]` is the parameter type for parsers
- [ ] The CLI handles a missing file with a message and a non-zero exit code
- [ ] `git tag S1`

## Teach-back
Explain to your mentor, in your own words, what happens in memory when you
call `hexdump(&bytes)`: who owns the buffer, what `&bytes` is, and why the
function can't free it.

## Rust lens (summary)
Ownership, moves, `Copy`, shared vs. mutable borrows, slices, `chunks`,
`enumerate`, `fmt::Write`, `Result` with `?` in `main`, clippy `ptr_arg`.

## Capstone state after this tutorial
S1: `wg-core::hexdump`, `wg hexdump <file>`.

## Further reading
Rust Book ch. 4 (ownership) and 9 (errors). `std::slice` docs: `chunks`,
`split_at_checked`, `get`.
