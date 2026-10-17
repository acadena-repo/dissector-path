# 24. Staff-level capstone defense

Phase: 5 | Time: ~16 h | Capstone: S23 -> S24
Prerequisites: tutorial 23; weak spots listed in MEMORY.md
Status: outline (ask your mentor: "Next tutorial" to expand it into full form,
tailored to your current capstone state and weak spots)

## Goal
Operate at staff scope: write the design doc for Wireglass v1.0, run a design review, review someone else's code, and plan the roadmap, mentoring, and standards that make a team faster and safer.

## Predict first
1. What distinguishes a staff engineer's output from a senior engineer's output?
2. How do you give a review that raises the bar without blocking progress?
3. What would you cut to ship v1.0 in half the time?

## Parts
### Part 1
Design doc for v1.0: goals, non-goals, architecture, alternatives, risks, rollout, metrics, open questions.

### Part 2
Peer-review exercise: review a mentor-provided flawed dissector PR using your checklist; write the review as if for a junior colleague.

### Part 3
Standards: write the team's dissector quality bar, protocol onboarding checklist, and on-call runbook for dissection issues.

### Part 4
Mentoring: write a tutorial for a new protocol as if training the next engineer; the mentor plays the newcomer.

### Part 5
Capstone defense: 30-minute presentation plus Q&A on any decision in the ADR log.

## Exercises
1. Run a retrospective on the full path: top 5 lessons, top 3 regrets.
2. Create a 12-month personal development plan (depth areas, scope growth).
3. (stretch) Contribute a fix or parser improvement upstream to an open-source project (Suricata, Zeek, Wireshark, or a Rust crate).

## Exit criteria
- [ ] Design doc, runbook, and standards committed
- [ ] Written review of a flawed PR judged thorough and constructive by the mentor
- [ ] Capstone defense passed with a clear answer on every ADR challenged
- [ ] All skill ratings re-assessed with evidence; plan for rows below 4
- [ ] `just check` green; MEMORY.md updated; `git tag S24`

## Teach-back
Teach a new engineer how to add a protocol to Wireglass in one hour.

## Rust lens (summary)
API stability and semver at a team level, code review craft, documentation as a product, deprecation policy.

## Capstone state after this tutorial
S24: see the goal and parts above. Your mentor records the exact state in
MEMORY.md when you finish.

## Further reading
'Staff Engineer' (Larson); 'The Staff Engineer's Path' (Reilly); Google engineering practices on code review.
