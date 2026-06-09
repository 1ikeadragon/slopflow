---
name: rigorous-web-research
description: Current external research with hard citations: official docs, competitor practice, recent papers, benchmarks, advisories, and release notes. Use when a decision or implementation would materially benefit from current external evidence, when facts may be stale, or when the user asks to research, look up, compare tools, or find current best practices. Every substantive external claim must carry a source URL. Not for claims about the local codebase (use evidence-first).
version: 2.0.0
---

# Rigorous Web Research

Use this skill when implementation, design, product, architecture, security, performance, or technical recommendations would materially benefit from current external evidence. Use it when the answer may be stale, the decision has meaningful cost, or external practice could change the approach — not for every task. Do not rely on memory for volatile facts: if there is more than a small chance the fact changed, verify.

## Hard Citation Requirement

Every substantive external claim — web-derived facts, competitor behavior, pricing, API behavior, benchmark results, release details, research claims, best-practice claims — must include a source URL **in the final answer**, not only in private notes. If a claim is inferred from sources, cite the source and label it as inference. If browsing tools are unavailable, say current web research could not be performed; do not imply a claim was verified online.

## Workflow

1. **State the research question** and the decision it informs, plus what evidence would change your recommendation. Split broad questions into focused subquestions.
2. **For non-trivial questions, start with 2-4 competing hypotheses**, each with the evidence that would support or weaken it. Do not search only to confirm a preferred answer.
3. **Map the space broadly, then narrow to primary sources.** Compare at least two independent sources for important claims.
4. **Convert findings into implementation implications**, and state what was not checked.

## Source Strategy

Prefer, in order:

1. Primary sources: official docs, specs, standards, release notes, API references, source repos, changelogs, RFCs.
2. Primary evidence from competitors: their product docs, public pricing, engineering blogs about their own systems, changelogs.
3. Peer-reviewed or preprint research, with publication date and limitations.
4. Reputable engineering blogs, incident reports, benchmark writeups.
5. Community sources only for leads and practical caveats — not authoritative without corroboration.

Record dates: publication, last-updated, version, and access date for volatile pages. When sources conflict, check version and scope first; prefer the newer source only when it covers the same version/scope. Newer is not automatically better. Preserve unresolved conflicts instead of forcing a conclusion.

## Competitor / Market Scans

Define the comparison set and why each example is relevant. Separate observed public behavior from inferred internals; state what cannot be known externally. Identify common patterns and meaningful outliers; avoid overfitting to a single competitor.

## Quality Bar

Every important conclusion should carry: the claim, its source URL(s), a proof level (primary source / corroborated secondary / single secondary / inference), the date/version, limitations, and its implementation implication. Avoid vague summaries like "people do X" unless the sources actually support it.

Report research shortcuts as signal loss: skipped source classes, paywalled material, biased search terms, reliance on one vendor's docs, no primary source found.

## Output

```text
Research question:
Findings:            # each substantive claim cited
Proven by primary sources / corroborated / inferred / still unknown:
Implementation implications:  # must do / should do / avoid / open questions
Risks and limitations:
Sources:             # exact URLs used
```

Do not paste research into implementation without checking the local production path: external practice informs the decision; local code determines where and how to change behavior. End by stating what the research implies for the implementation, recommendation, or next step.
