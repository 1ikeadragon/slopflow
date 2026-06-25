---
name: agent-system-design
description: Design, review, or improve agentic systems with LLM loops, tools, memory/state, handoffs, subagents, guardrails, tracing, evaluations, or agent prompts. Use for agent architecture, agent implementation plans, prompt/skill design for agents, tool-contract design, multi-agent vs single-agent decisions, production-readiness reviews, and avoiding no-op agent instructions.
---

# Agent System Design

Use this after `reasoning-discipline` has framed the task. If the work touches an existing codebase, pair it with `evidence-first` or `architecture-review` before proposing changes.

## Source Map

Read `references/source-map.md` when the user asks for external best practices, source-backed recommendations, framework/pattern selection, or citations in a design artifact. Do not load it for purely local prompt cleanup unless a claim needs support.

## Workflow

1. Restate the job in agent terms:
   - User-visible goal and unacceptable failure.
   - Environment the agent can observe and change.
   - Success signal, feedback loop, and stop condition.
   - Side effects that need policy, permission, or human review.

2. Decide whether an agent is justified:
   - Prefer a deterministic workflow or augmented single LLM call when steps are known, success is easy to validate, and autonomy adds little.
   - Use an agent loop when the task requires dynamic tool choice, iterative observation, long-running correction, or ambiguity that cannot be captured cleanly in fixed branches.
   - Add multi-agent structure only when one agent is overloaded by incompatible tool domains, ownership boundaries, or context requirements. Name the coordination cost.

3. Map the runtime contract:
   - Control flow: loop owner, handoff rules, pause/resume path, retry path, and termination.
   - Context: what enters the context window, what is retrieved, what is summarized, and what must never be summarized away.
   - State: conversation state, business state, execution state, durable checkpoints, and recovery after failure.
   - Tools: data tools, action tools, orchestration tools, schemas, permission boundaries, idempotency, error surfaces, and test fixtures.
   - Side effects: writes, money movement, messages, file changes, shell commands, network calls, and irreversible actions.

4. Choose the simplest architecture that can meet the contract:
   - Fixed workflow: known sequence with gates.
   - Router: classify then send to a specialized path.
   - Single agent with tools: one loop owns context, decisions, and final output.
   - Manager with specialist tools: one visible owner delegates bounded subtasks.
   - Handoff graph: control transfers between specialists; use only when ownership truly changes.
   - Parallel read-only subagents: acceptable for search, summarization, or independent analysis when their outputs are reconciled by one decision owner.
   - Parallel writers: avoid by default. If used, require shared context, explicit ownership of files/resources, conflict resolution, and review before merge.

5. Design prompts and skills as executable policy, not motivational prose:
   - Keep an instruction only if it changes a trigger, decision boundary, allowed action, output shape, validation step, handoff rule, or failure behavior.
   - Replace "be thorough", "write clean code", "make a detailed commit message", and similar no-ops with observable requirements.
   - Prefer checklists with required evidence over adjectives.
   - Tie each prompt variable to a runtime source, default, validation rule, or refusal path.

6. Add guardrails and human review next to the risk:
   - Validate inputs before expensive or side-effecting work.
   - Validate tool arguments/results around the tool that creates risk.
   - Validate final outputs before user or external-system release.
   - Pause for human approval before sensitive side effects; persist enough state to resume safely.
   - Do not rely on a single global guardrail if lower-level tools can be reached through handoffs or nested agents.

7. Define evaluation and observability before calling the design production-ready:
   - Golden tasks with expected final outcomes and expected tool trajectories.
   - Regression tests for prompt, tool-schema, routing, and memory changes.
   - Trace coverage for LLM calls, tool calls, handoffs, guardrails, retries, approvals, and final output.
   - Oracle audit for any reported accuracy, pass rate, cost, or latency number.
   - Sandbox tests for autonomous loops and side-effecting tools.

## Output

For a design or review, return:

- Agent fit: why agentic behavior is or is not justified.
- Proposed architecture: loop owner, tools, context/state, control flow, side effects, and stop condition.
- Prompt/tool contracts: concrete instructions, schemas, validation, and failure behavior.
- Guardrails and approvals: where they run and what they block, pause, redact, or escalate.
- Evals and observability: golden cases, trajectory checks, trace requirements, and unmeasured risks.
- Complexity justification: why simpler patterns were insufficient, or which complexity was rejected.

## No-Op Filter

Before finalizing any prompt, skill, or instruction set, run this filter:

- If deleting the sentence would not change a tool call, artifact, decision, validation step, or refusal/escalation path, delete it.
- If a sentence only states a virtue, convert it into a concrete check or remove it.
- If two instructions compete, name the priority rule.
- If an instruction cannot be evaluated from output, trace, or code behavior, mark it as preference rather than requirement.
