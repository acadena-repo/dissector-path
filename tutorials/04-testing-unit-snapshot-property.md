# 04. Testing: unit, snapshot, property

Phase: 1 | Time: ~8 h | Capstone: S3 -> S4
Prerequisites: tutorial 03; Rust Book ch. 11
Status: full

## Goal
Build the test harness that every later dissector uses: well-organized unit
tests, fixtures from real captures, snapshot ("golden") tests, and
property-based tests that assert your parsers never panic. This is the
habit that separates a good dissector engineer from a risky one.

## Predict first
1. What is the difference between a unit test in `#[cfg(test)] mod tests` and a file in `crates/wg-core/tests/`? Which can see private items?
2. If you feed 10,000 random byte strings to `Ethernet::parse`, what property should hold regardless of input?
3. A snapshot test fails after you improve the output format. Is the test wrong, the code wrong, or neither? What do you do?
4. Why is a round-trip property (`parse(serialize(x)) == x`) strong evidence for a parser, and what does it *not* prove?

## Parts

### Part 1: Test layout and conventions
- Unit tests: `#[cfg(test)] mod tests` inside each file, testing private details.
- Integration tests: `crates/wg-core/tests/*.rs`, using only the public API, as a user of the crate would.
- Fixtures: small binary files in `crates/wg-core/tests/fixtures/`, loaded with `include_bytes!("fixtures/eth_ipv4_tcp.bin")` (compile-time embedded, path relative to the file).
- Naming: `what_when_then`, for example `ipv4_with_options_reports_options_slice`.
- Integration test files are separate crates: they do not inherit the `cfg_attr(test, ...)` from `lib.rs`. Add the same `#![allow(clippy::unwrap_used, clippy::expect_used, clippy::indexing_slicing)]` at the top of each integration test file.

Task: extract 3 real frames from your captures into fixtures
(`tshark -r x.pcap -c 1 -x`, then convert hex to binary with `xxd -r -p`), and
write an integration test for each asserting the parsed fields.

Rust lens: `assert_eq!` with `Debug` output; use `matches!` for enum checks;
return `Result<(), Box<dyn Error>>` from tests to use `?` instead of `unwrap`.

### Part 2: Table-driven tests
Write one test iterating over `(name, bytes, expected)` tuples. When it fails,
the message must say which case failed (include `name` in the assertion).
Use this for malformed inputs: a list of 15+ truncated or corrupt frames with the
expected `ParseError` variant.

### Part 3: Snapshot tests with `insta`
Add to `wg-core/Cargo.toml`:
```toml
[dev-dependencies]
insta = "1"
proptest = "1"
```
(Check the current major versions.) Install the review tool: `cargo install cargo-insta`.

Write a test that dissects a fixture and snapshots the `Debug` or pretty
output: `insta::assert_debug_snapshot!(frame);`. First run creates a pending
snapshot; review with `cargo insta review` and accept. Commit `.snap` files.

When to use snapshots: large structured outputs that you inspect once and then
want to detect *any* change in. When not to: precise logic that deserves
explicit assertions.

Rust lens: snapshot output depends on `Debug` derives, so keep derives stable;
review every diff as a code review, not as noise.

### Part 4: Property-based tests with `proptest`
Properties for dissectors, in order of importance:
1. **Never panics:** for *any* `Vec<u8>`, parsing returns `Ok` or `Err`.
2. **Bounds:** parsed slices lie inside the input (`payload.len() <= input.len()`).
3. **Consistency:** `Reader` position plus remaining bytes equals the input length.
4. **Round trip:** for types with a serializer (`EtherType`, later headers), `from(into(x)) == x`.

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn ethernet_never_panics(bytes in proptest::collection::vec(any::<u8>(), 0..200)) {
        let _ = Ethernet::parse(&mut Reader::new(&bytes));
    }

    #[test]
    fn ethertype_roundtrips(x in any::<u16>()) {
        prop_assert_eq!(u16::from(EtherType::from(x)), x);
    }
}
```
If proptest finds a failure it *shrinks* the input to a minimal case and saves
it in `proptest-regressions/`. Commit that file: it is a permanent regression test.

Experiment: temporarily introduce a bug (index `buf[14]` without a check) and
watch proptest find it. Then fix it. Write down how many cases it needed.

Rust lens: `any::<T>()` strategies, `prop_assert!`, shrinking. Strategies can
also *build structured packets* (generate valid headers, then mutate): try one for IPv4.

### Part 5: Coverage and test runners
```bash
cargo nextest run                       # faster, clearer output
cargo install cargo-llvm-cov            # needs: rustup component add llvm-tools-preview
cargo llvm-cov --workspace --html       # then open target/llvm-cov/html/index.html
```
Find lines in `ipv4.rs` not covered. Are they error paths? Error paths are
where parsers fail, so cover them deliberately.

Coverage is a flashlight, not a goal: 100% line coverage with no assertions
on edge cases is worthless.

### Part 6: Wire it into the workflow
- `just check` already runs `cargo test --workspace`; add `cargo nextest run` as `just nextest`.
- Add the coverage command as `just cov`.
- Add a short `TESTING.md` in `capstone/` describing: where fixtures live, how to add one, how to review snapshots, and the rule "every bug becomes a regression test".

## Exercises
1. (core) Add 10 more malformed-input cases to the table test (zero bytes, 1 byte, truncated VLAN tag, IHL=0, IHL=15 with short buffer...).
2. (core) Write a property: for any valid IPv4 header you construct, `checksum_valid()` is true after you compute and insert the checksum.
3. (core) Introduce a deliberate off-by-one in `Reader::take` and note which test layers catch it (unit, table, property, snapshot). Which caught it first?
4. (stretch) Write a proptest strategy producing *valid* Ethernet+IPv4 frames, parse them, and assert fields equal the generated ones.
5. (stretch) Read about mutation testing (`cargo-mutants`) and run it on `reader.rs`. How many mutants survive?

## Exit criteria
- [ ] 3 real-capture fixtures with integration tests
- [ ] A table-driven malformed-input test with at least 15 cases
- [ ] At least one snapshot test, with snapshots committed and reviewed
- [ ] Property tests: never-panics for `Reader`, `Ethernet`, `Ipv4`; round-trip for `EtherType`
- [ ] You saw proptest find and shrink a real bug you injected
- [ ] Coverage report generated and uncovered error paths addressed or justified
- [ ] `capstone/TESTING.md` written; `just check` green; `git tag S4`

## Teach-back
Explain the testing pyramid for a dissector (unit, property, snapshot,
fuzz, differential), what class of bug each layer catches best, and why
fuzzing (tutorial 08) is still needed after property tests.

## Rust lens (summary)
`#[cfg(test)]`, integration tests, `include_bytes!`, dev-dependencies,
`matches!`, tests returning `Result`, `proptest` strategies, `insta`.

## Capstone state after this tutorial
S4: a test harness with fixtures, table tests, snapshots, property tests, and
coverage. Milestone M1 (Rust-literate) reached: schedule the oral assessment
with your mentor and re-rate skills in MEMORY.md.

## Further reading
Rust Book ch. 11. `proptest` book. `insta` docs. Cargo Book: dev-dependencies.
