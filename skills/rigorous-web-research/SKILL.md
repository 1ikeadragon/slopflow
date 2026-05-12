---
name: rigorous-web-research
description: This skill should be used when the user asks to "research", "look up", "find current best practices", "see what competitors do", "latest research", "blogs", "papers", "benchmarks", "market scan", "compare tools", "implement something using current docs", or when solving or implementing a problem would materially benefit from current external evidence, competitor practice, primary documentation, recent research, or online examples.
version: 1.0.0
---

# Rigorous Web Research

Use this skill when implementation, design, product, architecture, security, performance, or technical recommendations would materially benefit from current external evidence. The goal is to understand what reliable external sources, competitors, standards, docs, recent research, and practitioners are doing before deciding.

Do not use this skill for every task. Use it when the answer may be stale, the decision has meaningful cost, the user asks for current research, or external practice could change the implementation approach.

## Trigger Conditions

Use this skill for:

- current implementation guidance from official docs
- competitor or market scans
- recent papers, benchmarks, standards, advisories, and release notes
- library/framework/API behavior that may have changed
- product decisions informed by how others solve the problem
- security, legal, medical, financial, or policy-sensitive claims
- expensive build/buy/tooling decisions
- unclear best practices where online examples may reveal common patterns or pitfalls
- implementation tasks where current provider docs are the source of truth

Do not rely on memory for volatile facts. If there is more than a small chance the fact changed, verify.

## Research Question First

Before searching, state:

```text
Research question:
- ...

Decision this research informs:
- ...

What would change my implementation/recommendation:
- ...
```

If the question is broad, split it into focused subquestions.

## Competing Hypotheses

For non-trivial research, start with 2-4 plausible hypotheses:

```text
Hypotheses:
- H1: ...
  Evidence that would support it: ...
  Evidence that would weaken it: ...
- H2: ...
  Evidence that would support it: ...
  Evidence that would weaken it: ...
```

Do not search only to confirm a preferred answer.

## Source Strategy

Prefer sources in this order:

1. Primary sources: official docs, specs, standards, release notes, API references, source repos, changelogs, RFCs, vendor docs.
2. Primary evidence from competitors: product docs, public pricing/docs, engineering blogs describing their own system, public demos, changelogs.
3. Peer-reviewed or preprint research, with publication date and limitations.
4. Reputable engineering blogs, incident reports, benchmark writeups, and practitioner posts.
5. Community sources only for leads, failure reports, and practical caveats. Do not treat them as authoritative without corroboration.

For technical implementation claims, rely on primary docs or source code when possible.

## Recency Discipline

Record dates:

- publication date
- last updated date if available
- version number
- accessed date for volatile pages

When sources conflict, prefer the newer source only if it is relevant to the same version/scope. Newer is not automatically better.

## Search Workflow

1. Define the research question and decision.
2. Identify source classes needed: docs, competitors, papers, blogs, benchmarks, issues, source code.
3. Run broad searches to map the space.
4. Narrow to primary sources and high-signal secondary sources.
5. Compare at least two independent sources for important claims.
6. Record contradictions and stale-source risk.
7. Convert findings into implementation implications.
8. State what was not checked.

## Competitor / Market Scan

When checking what competitors or comparable systems do:

- define the comparison set and why each example is relevant
- separate public product behavior from inferred internals
- capture screenshots or exact public docs only when needed
- avoid overfitting to a single competitor
- identify common patterns and meaningful outliers
- state what cannot be known externally

Use:

```text
Competitor / comparable systems:
- ...

Observed public behavior:
- ...

Inferred but not proven:
- ...

Implementation implications:
- ...
```

## Research Quality Bar

Every important conclusion should answer:

```text
Claim:
- ...

Source(s):
- ...

Proof level:
- primary source / corroborated secondary / single secondary / inference

Date/version:
- ...

Limitations:
- ...

Implementation implication:
- ...
```

Avoid vague summaries like "people do X" unless the sources actually support it.

## Handling Conflicts

When sources disagree:

- verify version and date
- check whether they discuss the same environment, API tier, region, pricing plan, or deployment mode
- prefer official docs for current behavior
- use issue trackers and forums to identify real-world caveats
- preserve unresolved conflict instead of forcing a conclusion

Use:

```text
Conflict:
- ...

Likely reason:
- version mismatch / scope mismatch / outdated source / unclear

Decision:
- ...

Residual uncertainty:
- ...
```

## Implementation Integration

After research, map evidence to concrete action:

```text
Implementation impact:
- Must do: ...
- Should do: ...
- Avoid: ...
- Open question: ...
```

Do not paste research into implementation without checking the local production path. External practice informs the decision; local code determines where and how to change behavior.

## Signal Loss And Shortcuts

Report shortcuts:

- skipped source classes
- paywalled or inaccessible material
- search terms that may bias results
- lack of competitor visibility
- reliance on one vendor's docs
- no benchmark reproduction
- no primary source found

Use:

```text
Research limitations:
- ...

Signal potentially lost:
- ...

How to reduce uncertainty:
- ...
```

## Output Format

Use this format when reporting research:

```text
Research question:
- ...

Sources checked:
- ...

Findings:
- ...

Competitor / external practice:
- ...

What is proven vs inferred:
- Proven by primary sources: ...
- Corroborated: ...
- Inferred: ...
- Still unknown: ...

Implementation implications:
- ...

Risks / limitations:
- ...

Exact searches / source links:
- ...
```

## Final Rule

Research is useful only if it changes or validates a decision. End by stating what the research implies for the implementation, recommendation, or next step.
