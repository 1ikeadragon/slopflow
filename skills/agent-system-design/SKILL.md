---
name: agent-system-design
description: Design, review, or improve agentic systems with LLM loops, tools, memory/state, handoffs, subagents, guardrails, tracing, evaluations, or agent prompts. Use for agent architecture, agent implementation plans, prompt/skill design for agents, tool-contract design, multi-agent vs single-agent decisions, production-readiness reviews, and avoiding no-op agent instructions.
---

# Agent System Design

Use this after `reasoning-discipline` has framed the task. If the work touches an existing codebase, pair it with `evidence-first` or `architecture-review` before proposing changes.

## Source Map

Read `references/source-map.md` when the user asks for external best practices, source-backed recommendations, framework/pattern selection, citations in a design artifact, or component-level guidance for prompts, tools, context, state, orchestration, guardrails, evals, observability, cost, or security. Do not load it for purely local prompt cleanup unless a claim needs support.

## Workflow

1. Restate the job in agent terms:
   - Goal, unacceptable failure, environment, success signal, stop condition, and side effects needing review.

2. Decide whether an agent is justified:
   - Prefer a deterministic workflow or augmented single LLM call when steps are known, success is easy to validate, and autonomy adds little.
   - Use an agent loop when the task requires dynamic tool choice, iterative observation, long-running correction, or ambiguity that cannot be captured cleanly in fixed branches.
   - Add multi-agent structure only when incompatible tools, ownership boundaries, or context requirements justify the coordination cost.

3. Map the runtime contract:
   - Cover control flow, context, state, tools, side effects, guardrails, evals, observability, and operations.
   - For component-level checks and citations, read `references/source-map.md`.

4. Choose the simplest architecture that can meet the contract:
   - Consider fixed workflow, router, single tool-using agent, manager-worker, handoff graph, and read-only parallel analysis in that order.
   - Avoid parallel writers unless shared context, resource ownership, conflict handling, and one merge owner are explicit.

5. Design prompts and skills as executable policy, not motivational prose:
   - Keep an instruction only if it changes a trigger, decision boundary, allowed action, output shape, validation step, handoff rule, or failure behavior.
   - Replace "be thorough", "write clean code", "make a detailed commit message", and similar no-ops with observable requirements.

6. Place validation, guardrails, and human review next to the risk:
   - Validate inputs, tool arguments/results, and final outputs where failure would create cost, security exposure, data corruption, or external side effects.
   - Persist approval state and resume context for sensitive operations.

7. Define evaluation and observability before calling the design production-ready:
   - Include final-output checks, trajectory checks, prompt/tool/memory regression tests, trace coverage, oracle audits for reported metrics, and sandbox tests for side-effecting loops.

## Output

For a design or review, return agent fit, proposed architecture, prompt/tool contracts, guardrails and approvals, evals and observability, and complexity rejected or accepted. Use the minimum design artifact in `references/source-map.md` for serious production systems.

## No-Op Filter

Before finalizing any prompt, skill, or instruction set, run this filter:

- If deleting the sentence would not change a tool call, artifact, decision, validation step, or refusal/escalation path, delete it.
- If a sentence only states a virtue, convert it into a concrete check or remove it.
- If two instructions compete, name the priority rule.
- If an instruction cannot be evaluated from output, trace, or code behavior, mark it as preference rather than requirement.
