# Protocol notes: NAME

## Identity
- Standard / spec and version:
- Transport and ports (TCP/UDP/L2), multicast or broadcast use:
- Typical devices and vendors:
- Authentication / integrity (usually none for ICS):

## Framing
- Header layout (offset, size, endianness, meaning):
- Length field semantics (what it counts, max size):
- How to find message boundaries on a TCP stream:
- Resynchronization after garbage:

## Messages
| Code | Name | Direction | Fields | Risk (read / write / control / firmware) |
|---|---|---|---|---|

## State
- Session setup and teardown:
- Request/response correlation (ids, sequence numbers):
- Fragmentation / segmentation:

## Quirks seen in real captures
- Spec violations, vendor extensions, ambiguities:

## Detection-relevant fields
What an analyst or detection engine needs from this protocol.

## Test corpus
| Capture | Source | What it covers |
|---|---|---|

## Open questions
