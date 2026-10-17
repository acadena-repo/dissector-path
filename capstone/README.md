# Wireglass (capstone)

A passive, high-performance network traffic dissection engine with an ICS/OT
focus, built step by step through the tutorials. Wireglass observes traffic and
never transmits.

## Target architecture (reached at S24)

```
 capture            reassembly          dissection             output
+---------+       +-----------+       +--------------+       +-----------+
| pcap /  |  -->  | flow table|  -->  | dissector    |  -->  | structured|
| AF_PACKET|      | TCP reasm |       | registry     |       | records   |
| ring    |       | (bounded) |       | Modbus DNP3  |       | (serde /  |
+---------+       +-----------+       | ENIP S7 ...  |       | protobuf) |
     |                  |             +--------------+       +-----------+
     +----- shard by flow hash across worker threads -----+        |
                                                              metrics, tracing
```

## Crate plan (crates appear when a tutorial needs them)

| Crate | Introduced | Role |
|---|---|---|
| `wg-core` | S0 | Reader, errors, shared types |
| `wg-cli` | S0 | `wg` binary |
| `wg-net` | 06 | Ethernet, IP, TCP, UDP parsers |
| `wg-pcap` | 05 | pcap/pcapng reading |
| `wg-flow` | 09 | Flow table, TCP reassembly |
| `wg-dissect` | 11 | Dissector trait, registry |
| `wg-proto-*` | 07+ | One crate per protocol (modbus, dnp3, enip, ...) |
| `wg-capture` | 16 | Live Linux capture |
| `wg-service` | 17 | Async service shell |
| `wg-fuzz` | 08 | cargo-fuzz targets (outside the workspace) |

## Design rules

See `../RUST-TRACK.md` section 2 (the ten rules of a dissector).

## State tags

`S0` scaffold, `S1` hexdump, `S2` Reader and errors, `S3` Ethernet/IPv4 ... see
`../ROADMAP.md` for the full table. Record the current tag in `../MEMORY.md`.
