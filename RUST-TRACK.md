# RUST-TRACK.md

Idiomatic, high-quality Rust for protocol dissectors. The mentor uses this file
for every "Rust lens" and every code review.

## 1. Proficiency ladder (mapped to tutorials)

| Level | You can... | Reached in |
|---|---|---|
| R1 | Build, run, test; use `Vec`, `String`, slices, `match`, `Option`, `Result` | 00-02 |
| R2 | Reason about ownership and borrowing without trial and error; write traits and generics; read lifetime errors | 03-04 |
| R3 | Design zero-copy APIs with lifetimes; model errors well; use iterators fluently; organize modules and crates | 05-08 |
| R4 | Design trait-based frameworks; choose generics vs trait objects; manage bounded state; write fast safe code and measure it | 09-15 |
| R5 | Use async and threads correctly; wrap `unsafe`/FFI soundly; design public APIs others extend | 16-23 |

## 2. The ten rules of a dissector (non-negotiable)

1. **Never panic on wire data.** No `unwrap()`, `expect()`, `[i]`, `[a..b]`, or `+`/`*` on lengths taken from packets. Use `get()`, `checked_add`, `checked_mul`, `try_into`, and return errors.
2. **Three outcomes, not two.** `Incomplete { needed }` (wait for more bytes), `Malformed(reason)` (corrupt or not this protocol), `Unsupported(what)` (valid but not decoded). Callers handle each differently.
3. **Borrow, don't copy.** Parsed structs hold `&'a [u8]` into the input. Copy only when data must outlive the buffer, and say why.
4. **Bound everything.** Lengths, counts, nesting depth, per-flow memory, reassembly buffers. An attacker controls every number on the wire.
5. **Unknown is a value.** Protocol enums carry `Unknown(u8)`; unknown function codes are data, not errors.
6. **Return the remainder.** Parsers consume a prefix and hand back the rest, so pipelined messages in one stream work.
7. **Validate early, trust late.** Check lengths and invariants at the boundary; inner code then works with already-validated types (newtypes).
8. **Make illegal states unrepresentable.** Enums with data over booleans and optional fields; state machines as enums.
9. **Test hostile input.** Unit + property (`never panics`) + fuzz + differential (tshark). Every bug becomes a regression fixture.
10. **Measure before optimizing.** Simple reference implementation first, benchmark, profile, then change one thing.

## 3. Newbie traps and how to get out

| Trap | Symptom | Fix |
|---|---|---|
| Fighting the borrow checker with `.clone()` everywhere | Works, but slow and hides design flaws | Ask "who owns this data?"; restructure so one owner and many borrowers |
| `&Vec<u8>` / `&String` parameters | Clippy `ptr_arg` | Take `&[u8]` / `&str` |
| `unwrap()` "just for now" | Panics on first malformed packet | Return `Result`, use `?` |
| Indexing `buf[3]` | Panic on short input | `buf.get(3).ok_or(...)?` or a `Reader` |
| `as` casts on untrusted values | Silent truncation | `u16::try_from(x)`, `usize::from(u8)` |
| Giant `match` on raw integers | Magic numbers | Enum + `From<u8>` with `Unknown` |
| Stringly-typed errors | Cannot match on them | Error enums (`thiserror`) |
| Lifetime annotations "until it compiles" | Confusing signatures | Learn elision rules; struct borrows from input = one `'a` |
| `Box<dyn Trait>` by reflex | Allocation, indirection | Start with enums or generics, measure |
| Premature `unsafe` | Soundness risk | Forbid it (`unsafe_code = "forbid"`) until tutorial 23 |

## 4. Language features by importance for this work

- **Ownership, borrowing, slices**: the core of zero-copy parsing.
- **`Result`, `Option`, `?`, error enums**: all control flow on bad input.
- **Enums and `match`**: protocol codes, state machines, layered dispatch.
- **Traits and generics**: `Parse<'a>`, dissector interfaces; know `impl Trait`, `dyn Trait`, associated types.
- **Lifetimes**: `struct Frame<'a> { data: &'a [u8] }`, `impl<'a>`, elision.
- **Iterators**: `chunks`, `windows`, `zip`, `fold`, custom iterators over packets.
- **Modules, crates, workspaces, features**: structure large systems.
- **Integer semantics**: `from_be_bytes`, `checked_*`, `saturating_*`, `try_from`.
- **Concurrency**: `Send`/`Sync`, channels, `Arc`, `Mutex` (and why to avoid sharing).
- **Async**: only where I/O-bound (service layer), never in the parse hot path.
- **`unsafe`/FFI**: last, small, audited.

## 5. Crate map

| Need | Crates | Notes |
|---|---|---|
| Errors | `thiserror` (libs), `anyhow` (bins) | Libraries expose enums, binaries may use `anyhow` |
| Parsing | hand-written slices first, then `winnow` or `nom`; `binrw`/`deku` for declarative structs | Compare on one protocol before standardizing |
| Bytes | `bytes`, `memchr`, `smallvec` | After measuring |
| Packets | `etherparse`, `pcap-parser`, `pnet`, `smoltcp` | Learn from them; build your own first |
| Testing | `proptest`, `insta`, `cargo-fuzz`, `cargo-nextest`, `cargo-llvm-cov` | Core of the quality bar |
| Benchmarks | `criterion`, `cargo-flamegraph`, `perf`, `dhat` | Measure always |
| Serialization | `serde`, `serde_json`, `prost` | Output schema |
| Observability | `tracing`, `tracing-subscriber`, `metrics` | Production readiness |
| Async | `tokio` | Service layer only |
| Concurrency | `crossbeam`, `rayon` | Sharding and batch work |
| Linux | `libc`, `nix`, `socket2`, `aya` | Capture and eBPF |

## 6. Code review checklist (mentor and self-review)

Correctness
- [ ] Every read is bounds-checked; no panics possible on any input
- [ ] Incomplete, Malformed, Unsupported are distinguished and tested
- [ ] Length arithmetic uses checked operations; caps on declared lengths
- [ ] Endianness is explicit (`from_be_bytes`/`from_le_bytes`)
- [ ] Remainder is returned; no infinite loops on zero-length progress

Idiom
- [ ] Parameters take `&[u8]`/`&str`, not `&Vec`/`&String`
- [ ] No needless `clone()`, `to_vec()`, or `String` allocations
- [ ] Types express meaning (newtypes, enums) instead of bare integers
- [ ] Public API is small, documented (`///`), with examples that run as doc tests
- [ ] Clippy clean with `-D warnings`; `cargo fmt` applied

Quality
- [ ] Unit tests for each field, property test for no-panic, fixture from real capture
- [ ] Fuzz target exists for every public parse entry point (from tutorial 08)
- [ ] Decision recorded in an ADR if it was a real trade-off
- [ ] Benchmarks exist before any optimization claim

## 7. Reading list (in this order)

1. *The Rust Programming Language* ("the book"): chapters 1-10 during Phase 1, 13, 15-16 during Phase 3-4, 17 before tutorial 17.
2. *Rust by Example* and **Rustlings**: short drills in parallel with Phase 1.
3. *Rust API Guidelines* and *Rust Design Patterns*: before tutorial 11.
4. *Programming Rust* (Blandy, Orendorff, Tindall) or *Rust for Rustaceans* (Gjengset): after tutorial 08.
5. *The Rustonomicon*: before tutorial 23.
6. Source reading: `smoltcp`, `etherparse`, Wireshark dissectors, Zeek ICS analyzers, Suricata's Rust app-layer parsers.
7. Protocol specs: Modbus Application Protocol, IEEE 1815 (DNP3), ODVA CIP/EtherNet/IP overviews, relevant public Wireshark wiki pages.

(Verify current editions and links; they change.)
