---
name: reasoning-discipline
description: The reasoning spine for non-trivial, ambiguous, open-ended, or high-stakes work frame the problem, generate structurally different options, verify load-bearing claims, diagnose with competing hypotheses, evaluate against weighted criteria, decide under uncertainty, and synthesize — executed via mode files read one at a time with a todo ledger. Also holds the metric/oracle audit and meta-reasoning checks behind Core Rules 9-10. Use for design decisions, tradeoffs, "which approach" questions, planning, and before reporting any count, cost, accuracy, or pass/fail number. Engage on your own when the work warrants it; skip for trivial or mechanical tasks.
version: 3.0.0
---

# Reasoning Discipline

The domain skills enforce *evidence* discipline: what is true in the code or system. This skill enforces *reasoning* discipline: how to think before converging. It is for tasks where the answer is not a lookup: open-ended problems, design and architecture decisions, tradeoffs, planning, and high-stakes judgment. It composes with every domain skill.

## Orient first

Before reasoning, state the frame in a line or two:

- Goal: what the user is actually trying to accomplish, not just the literal request.
- Failure: what would go wrong if you answered now without thinking it through.
- Constraints: hard requirements, soft preferences, and unknowns.
- Evidence: whether facts, files, tools, tests, or measurements could change the answer. If so, get them before concluding.
- Output: what the answer must be (artifact, recommendation, diagnosis, plan, critique, or direct answer).

If a missing detail would materially change the goal, constraints, or output, proceed with a stated assumption and flag it. Do not confuse satisfying the user's framing with serving the user's goal.

## Pick the moves

Each move has a mode file in `references/`. Chain only the moves the task needs; most tasks need a few, not all. Match depth to stakes.

| Move | File | Use it to |
| --- | --- | --- |
| Frame | `references/frame.md` | expose hidden assumptions and reframe before solving |
| Generate options | `references/generate.md` | expand the option space with structurally different branches |
| Verify | `references/verify.md` | check load-bearing claims against external evidence |
| Diagnose | `references/diagnose.md` | turn symptoms into competing hypotheses with distinguishing evidence |
| Evaluate | `references/evaluate.md` | weigh options or artifacts against weighted criteria |
| Decide | `references/decide.md` | commit to one direction under uncertainty |
| Synthesize | `references/synthesize.md` | integrate parts into one coherent, usable whole |
| Taste | `references/taste.md` | judge form, naming, docs, and UI from an explicit point of view |

Common chains:

- Tricky bug or failure: Diagnose → Verify.
- Design, RFC, or "which approach": Frame → Generate options → Evaluate → Decide.
- Reviewing a complex change: Frame → Evaluate → Verify.
- Open-ended or ambiguous problem: Frame → Generate options → Evaluate → Decide → Synthesize.
- Root-cause analysis: collect runtime evidence (`workflow-rca`) → Diagnose → Verify → Synthesize.
- Cleanup or removal: Frame → Verify reachability → Decide.

## Run the ledger

Decide the chain *before* reading any mode file, then keep a todo ledger of the selected moves:

```text
[ ] frame
[ ] generate
[ ] decide
```

Read the first mode's file. Based on it, expand that move into sub-items: the specific questions it must answer or evidence it must gather. Mark a move done only when its sub-items are answered or you honestly could not answer them. Then move to the next mode, carrying forward only the insight, open questions, and uncertainty the next move needs.

Read one mode file at a time, at the moment you run that move. Do not read several upfront, and do not skip reading a mode because the move "seems obvious" — the file is what keeps the move honest late in a long context. If a mode redirects to one you already completed, reuse those results unless the situation materially changed.

## Subagents

When the work needs extensive reading, external observation, or has materially distinct angles that can be explored independently, delegate to subagents; this gathers information without spending your own reasoning context. Run independent angles in parallel and continue critical-path work while they run. Give each subagent a precise return contract, and treat what comes back as evidence to verify, not as settled fact.

## Metric and oracle audits

Before reporting any cost, count, accuracy, or pass/fail number from logs, traces, or test runs, read `references/audits.md` and run it: canonical source, double-counting across layers, precise denominator, oracle lineage, and excluded cases.

## Meta-level checks: before finalizing

On every non-trivial conclusion:

- Identify the load-bearing claim, the evidence for it, and the evidence that would disprove it.
- Hunt for alternative explanations, double-counting, selection or survivorship bias, denominator drift, stale artifacts, hidden retries, cached results, and mismatched source-of-truth boundaries.
- Treat neat stories, exact-looking numbers, inherited labels, and user-provided summaries as hypotheses until reconciled against primary evidence.
- If the answer hinges on a classification, threshold, oracle, or policy reading, ask whether it measures what the user thinks it measures.
- Do not optimize for sounding decisive. If the honest result is "partly proven", "not measured", "contradicted", or "unclear", say so and name the next evidence that would settle it.
- For high-stakes or production-shaping claims, include a short adversarial self-check: what could be wrong, what was ruled out, and what remains unverified.

## Output discipline

Surface the criteria, assumptions, evidence, and uncertainty that change the user's action or understanding; omit the rest. Put caveats next to the claims they limit. Do not make the answer look more certain than the evidence permits. When constraints genuinely conflict, surface the conflict rather than pretending all of them can be satisfied. Self-evaluation is a filter, not proof: prefer external signals — tests, logs, calculations, sources, measurements — when available.
