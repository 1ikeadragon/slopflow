# Agent System Design Source Map

Use this file to ground agent-system recommendations. Prefer the source whose scope matches the decision; do not cite all sources by default.

Accessed: 2026-06-25.

## Core Architecture

- Anthropic, "Building effective agents": https://www.anthropic.com/engineering/building-effective-agents
  - Distinguishes workflows with predefined code paths from agents where the model dynamically directs tool use.
  - Recommends starting simple, adding complexity only when measured outcomes improve, and keeping the agent-computer interface explicit through tool documentation and testing.
  - Operationalize as: require an agent-fit statement, complexity justification, tool interface spec, and evaluation plan before adding loops or multi-agent structure.

- OpenAI, "A practical guide to building agents": https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/
  - Frames agent design around model choice, tools, instructions, orchestration, and guardrails.
  - Recommends prototyping with capable models to establish a baseline, then optimizing cost/latency after measuring acceptable quality.
  - Treats single-agent systems as the first scaling step and multi-agent systems as justified by complexity such as tool overload, specialized ownership, or handoff needs.
  - Operationalize as: start with one loop owner; split only after prompt/tool clarity and eval evidence show the single agent is failing.

- HumanLayer, "12 Factor Agents": https://github.com/humanlayer/12-factor-agents and https://www.humanlayer.dev/12-factor-agents
  - Emphasizes owning prompts, context window, control flow, execution/business state, human contact, and stateless reducer-style agent behavior.
  - Operationalize as: make prompt templates versioned artifacts, make context assembly explicit, keep control flow in application code where possible, and persist enough state for pause/resume/replay.

## Context And Multi-Agent Coordination

- Cognition, "Don't Build Multi-Agents": https://cognition.com/blog/dont-build-multi-agents
  - Argues that multi-agent systems fail when context and implicit decisions are fragmented across agents.
  - Operationalize as: default to single-threaded decision ownership; allow read-only subagents for evidence collection; require shared traces, explicit ownership, and reconciliation for parallel work.

- Cognition, "Multi-Agents: What's Actually Working": https://cognition.com/blog/multi-agents-working
  - Narrows the multi-agent case toward systems where multiple agents contribute intelligence while writes remain single-threaded.
  - Operationalize as: if parallelism is used, separate read/analysis work from writes and keep a single owner for final decisions and side effects.

## Runtime, State, And Observability

- OpenAI Agents SDK guide: https://developers.openai.com/api/docs/guides/agents
  - Separates running agents, sandboxed environments, handoffs, guardrails/human review, result state, tools, and observability.
  - Operationalize as: specify who owns orchestration, where state lives, how runs resume, and which traces must exist before production.

- OpenAI Agents SDK tracing docs: https://openai.github.io/openai-agents-python/tracing/
  - Documents tracing for end-to-end workflows, LLM generations, agent spans, tool calls, handoffs, guardrails, and custom events.
  - Operationalize as: require trace coverage for every model/tool/handoff/guardrail path that can affect the final decision.

- LangGraph overview: https://docs.langchain.com/oss/python/langgraph/overview
  - Positions LangGraph as low-level orchestration for long-running stateful agents, with persistence, human-in-the-loop, memory, and debugging.
  - Operationalize as: reach for graph runtimes when durable execution, state inspection, and pause/resume are requirements, not because a diagram looks cleaner.

## Guardrails, Human Review, And Evals

- OpenAI, "Guardrails and human review": https://developers.openai.com/api/docs/guides/agents/guardrails-approvals
  - Distinguishes input, output, tool guardrails, and human approvals; warns that guardrail boundaries differ by workflow level.
  - Operationalize as: put validation next to the risky tool or output, not only at the top-level agent, and pause before sensitive side effects.

- LangChain, "Human-in-the-loop": https://docs.langchain.com/oss/python/langchain/human-in-the-loop
  - Describes middleware that interrupts tool calls, persists graph state, and resumes after approve/edit/reject/respond decisions.
  - Operationalize as: model human review as a persisted state transition with explicit allowed decisions, not as a vague "ask a human" instruction.

- Google ADK eval codelab: https://codelabs.developers.google.com/adk-eval/instructions
  - Shows golden interactions, tool trajectory checks, metric troubleshooting, and CI integration through pytest.
  - Operationalize as: test both final answers and tool trajectories; audit whether a failed metric reflects a real behavior bug or a weak oracle.

## Prompt And Skill Quality

- Treat prompt instructions as policy. A useful instruction changes at least one observable behavior: trigger, allowed action, decision rule, output schema, validation, handoff, refusal, escalation, or stop condition.
- Delete no-op virtues. "Be thorough", "make it easy to read", "write a good commit message", and "think carefully" are not requirements unless converted into specific evidence, structure, or checks.
- Prefer source-bound prompts: each variable should have a runtime source, default, validation rule, and failure behavior.
