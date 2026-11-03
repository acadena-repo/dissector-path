# ADR-0001: Documentation strategy and decisions traceability

Date: 2026-11-01 | Status: Accepted
Tutorial: 00

## Context
The Protocol Dissector Path is covered thru six phases in 25 tutorials and one evolving capstone, where architectural decisions and technical constraints need to be documented in a succinct manner that allowing to preserve the reasoning behind technical and architectural decisions; being able to giving me, and my mentor track how those evolves, and maintain traceability between decisions and implementation changes.

## Options Considered

### Option A: Architecture Decision Records (ADRs) in `adr/`
Maintain individual Markdown files documenting significant architectural and technical decisions.

**Pros:**
- Provides a structured and consistent decision-making process.
- Preserves the historical reasoning behind architectural choices.
- Supports explicit relationships between decisions, including superseded or amended decisions.

**Cons:**
- Requires additional time to create and maintain.
- Can become outdated if changes are not reflected in subsequent decisions.
- May introduce unnecessary overhead for minor implementation changes.

### Option B: Git Commit Messages Only
Use Git commit messages as the primary mechanism for documenting decisions and their implementation.

**Pros:**
- No additional documentation files are required.
- Minimal additional workflow overhead.
- Git history provides chronological traceability.

**Cons:**
- Architectural reasoning becomes fragmented across multiple commits.
- Squashing, rebasing, or rewriting history can remove or consolidate the original reasoning.
- Commit history primarily describes implementation changes rather than the decision-making process.

## Decision
- **Option A: Architecture Decision Records (ADRs) in `adr/`,** because historical reasoning behind architectural decisions is more important than potential workflow overhead.
- Create an ADR when a decision changes the architecture, establishes a reusable design constraint, or introduces a trade-off that future tutorials may need to understand or reconsider. When a significant decision is replaced, a new ADR should be created and the previous ADR marked as superseded.

## Consequences
(+) Architectural decisions remain discoverable and understandable.   
(-) Documentation maintenance becomes part of the development workflow.   
Revisit if: ADRs creation takes more than 1 hour. Two tutorials in a row ship a significant change without an ADR.

## Evidence
ADR-0001 took 3 drafts, about 120 minutes, and came out at about 33 lines.
