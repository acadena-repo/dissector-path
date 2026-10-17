# Protocol Dissector Expert Path

A self-paced, mentor-driven program to become an expert **protocol dissector
engineer** and **senior Rust / Linux backend engineer**, building one evolving
system, **Wireglass**, a passive, high-performance network traffic dissection
engine (with an ICS/OT focus).

You start as a Rust newbie. Rust is taught *through* dissection: every tutorial
adds a piece to the capstone and a set of idiomatic-Rust lessons.

## Folder map

| Path | What it is |
|---|---|
| `WSL2-QUICKSTART.md` | Start here: set up WSL2, Rust, git, and VS Code (about 90 min) |
| `scripts/doctor.sh` | Checks that your environment is ready |
| `PROJECT_INSTRUCTIONS.md` | Text to paste into the Claude project's custom instructions |
| `MEMORY.md` | Your progress, ratings, weak spots, session log. Updated every session |
| `ROADMAP.md` | Phases, tutorial list, skill ladder, pacing |
| `RUST-TRACK.md` | Idiomatic Rust for dissectors: rules, crates, review checklist |
| `tutorials/` | The tutorial series (00-24). 00-04 are fully written, the rest are outlines expanded by your mentor when you reach them |
| `templates/` | Tutorial, ADR, and protocol-notes templates |
| `adr/` | Your architecture decision records |
| `protocol-notes/` | One notes file per protocol you study |
| `captures/` | Where public sample pcaps go (large files git-ignored) |
| `capstone/` | The Wireglass Cargo workspace |

## Quick start

0. Follow `WSL2-QUICKSTART.md` and run `bash scripts/doctor.sh`.
1. Create a Claude Project. Upload all files to project knowledge. Paste the
   block from `PROJECT_INSTRUCTIONS.md` into custom instructions.
2. Say **"Start session"**. The mentor runs Session 0 (baseline assessment).
3. Work through `tutorials/00-setup-and-workflow.md`.
4. After each tutorial, say **"Update my MEMORY.md"**, replace the file in this
   folder and in project knowledge with the returned version, and commit.

## The loop for every tutorial

1. Read the goal and answer the *predict* questions out loud or in writing.
2. Build the parts in `capstone/`, test-first.
3. Run `just check` (fmt, clippy with `-D warnings`, tests).
4. Do the exercises, then the **teach-back** (explain it to your mentor).
5. Meet every exit criterion, then update `MEMORY.md`.

## Commands you will use constantly (from `capstone/`)

```bash
just check      # fmt + clippy -D warnings + tests
just test       # tests only
just watch      # re-run tests on change (needs cargo-watch)
cargo doc --open
```

## Verification note

The scaffold code was written without access to a Rust compiler. If `just
check` fails on a fresh clone, that is a bug in the scaffold, not in you. Paste
the error to your mentor.
