# Verify

## Core move

Check load-bearing claims. If needed evidence is missing and can be obtained, obtain it. If it cannot be obtained, mark the uncertainty visibly.

Self-critique is not proof. Repeatedly rereading the same unsupported answer is weak verification.

## Choose the right check

Route the check to where the evidence lives:

- Claim about code behavior, production paths, or repository state: apply `evidence-first` — trace executable wiring, do not trust names or comments.
- Current external fact, docs, pricing, API behavior, or research: apply `rigorous-web-research` — primary sources with citations.
- Factual claim: source, quote, date, or authoritative reference.
- Calculation: recompute, inspect units, use a calculator when available.
- Code change: run tests, type checks, linting, or minimal examples when possible.
- Citation: confirm the source supports the specific sentence.
- Reasoning: test implications, edge cases, counterexamples, and contradictions.
- Constraint satisfaction: check each hard constraint directly.
- Reported number (count, cost, accuracy, pass/fail): run the metric and oracle audit in `references/audits.md`.

## Evidence gathering as subroutine

Gather evidence only when it can change the answer, confidence, scope, risk, or next action. Ask:

- What claim would I be making if I answered now?
- Which part is unsupported?
- What is the cheapest evidence that reduces the largest uncertainty?
- Is the source, test, log, or example relevant to the specific claim?

If verifying requires extensive reading or observing external reality, delegate to a subagent with a precise return contract, and treat what comes back as evidence to verify, not settled fact.

## Failure checks

- checking only easy claims while leaving the central claim unsupported
- trusting a title, snippet, or citation without checking support
- correcting a correct answer because a critique prompt implies an error
- treating fluency, length, or detail as evidence
- searching when the problem is conceptual and evidence is already available
- refusing or hedging when a direct check is available
- over-pruning unusual but correct answers

## Done when

The load-bearing claims are verified, revised, or labeled with visible uncertainty. Carry forward only verified claims, important unverified claims, evidence that changed the answer, and uncertainty that should be visible.
