# captures/

Place **public** sample captures here. Large files are git-ignored.
Tiny hand-made fixtures that are checked into tests live in `fixtures/`.

Sources (verify availability before relying on them):
- Wireshark SampleCaptures wiki (Modbus, DNP3, EtherNet/IP, S7comm, and more)
- Public ICS pcap collections on GitHub (search "ICS-pcap")
- Captures you generate yourself in a lab with simulators (for example
  `diagslave`/`pymodbus` for Modbus, `opendnp3` for DNP3)

Rules
- Never commit customer, employer, or otherwise sensitive captures.
- Record where each capture came from in `captures/SOURCES.md`.
- Anonymize before sharing anything, and keep fixtures under ~50 KB.
