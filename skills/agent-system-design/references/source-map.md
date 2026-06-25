# Agent System Design Source Map

Use this file to ground agent-system recommendations. Prefer the source whose scope matches the component being designed; do not cite every source by default.

Accessed: 2026-06-25.

## Source Index

- `anthropic-effective-agents` Anthropic, "Building effective agents": https://www.anthropic.com/engineering/building-effective-agents
- `anthropic-context` Anthropic, "Effective context engineering for AI agents": https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- `anthropic-context-cookbook` Anthropic cookbook, "Context engineering: memory, compaction, and tool clearing": https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools
- `anthropic-tools` Anthropic, "Writing effective tools for agents": https://www.anthropic.com/engineering/writing-tools-for-agents
- `anthropic-tool-use` Anthropic, Tool use with Claude: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
- `anthropic-prompting` Anthropic, Prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- `anthropic-evals` Anthropic, "Demystifying evals for AI agents": https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- `anthropic-caching` Anthropic, Prompt caching: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- `openai-agents` OpenAI, Agents SDK guide: https://developers.openai.com/api/docs/guides/agents
- `openai-agent-guide` OpenAI, "A practical guide to building agents": https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/
- `openai-reasoning` OpenAI, Reasoning models: https://developers.openai.com/api/docs/guides/reasoning
- `openai-latest-model` OpenAI, latest model guide: https://developers.openai.com/api/docs/guides/latest-model
- `openai-prompting` OpenAI, Prompt engineering: https://developers.openai.com/api/docs/guides/prompt-engineering
- `openai-function-calling` OpenAI, Function calling: https://developers.openai.com/api/docs/guides/function-calling
- `openai-structured-outputs` OpenAI, Structured Outputs: https://developers.openai.com/api/docs/guides/structured-outputs
- `openai-guardrails` OpenAI, Guardrails and human review: https://developers.openai.com/api/docs/guides/agents/guardrails-approvals
- `openai-agent-evals` OpenAI, Evaluate agent workflows: https://developers.openai.com/api/docs/guides/agent-evals
- `openai-eval-best-practices` OpenAI, Evaluation best practices: https://developers.openai.com/api/docs/guides/evaluation-best-practices
- `openai-tracing` OpenAI Agents SDK tracing: https://openai.github.io/openai-agents-python/tracing/
- `openai-sessions` OpenAI Agents SDK Sessions: https://openai.github.io/openai-agents-python/sessions/
- `openai-rate-limits` OpenAI, Rate limits: https://developers.openai.com/api/docs/guides/rate-limits
- `openai-rate-limit-cookbook` OpenAI cookbook, "How to handle rate limits": https://developers.openai.com/cookbook/examples/how_to_handle_rate_limits
- `mcp-resources` Model Context Protocol, Resources: https://modelcontextprotocol.io/specification/2025-06-18/server/resources
- `mcp-prompts` Model Context Protocol, Prompts: https://modelcontextprotocol.io/specification/2025-06-18/server/prompts
- `langgraph-persistence` LangGraph Persistence: https://docs.langchain.com/oss/python/langgraph/persistence
- `langchain-hitl` LangChain, Human-in-the-loop middleware: https://docs.langchain.com/oss/python/langchain/human-in-the-loop
- `langchain-context` LangChain, "Context engineering for agents": https://www.langchain.com/blog/context-engineering-for-agents
- `google-adk-memory` Google ADK Memory: https://adk.dev/sessions/memory/
- `google-adk-state` Google ADK State: https://adk.dev/sessions/state/
- `google-adk-eval` Google ADK eval codelab: https://codelabs.developers.google.com/adk-eval/instructions
- `owasp-prompt-injection` OWASP, LLM01 Prompt Injection: https://genai.owasp.org/llmrisk/llm01-prompt-injection/
- `owasp-llm-top-10` OWASP, Top 10 for LLM Applications: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- `opentelemetry-genai` OpenTelemetry, Generative AI instrumentation: https://opentelemetry.io/blog/2024/otel-generative-ai/
- `opentelemetry-semconv` OpenTelemetry GenAI semantic conventions: https://opentelemetry.io/docs/specs/semconv/gen-ai/
- `cognition-dont-build-multi-agents` Cognition, "Don't Build Multi-Agents": https://cognition.com/blog/dont-build-multi-agents
- `cognition-multi-agents-working` Cognition, "Multi-Agents: What's Actually Working": https://cognition.com/blog/multi-agents-working

## Component Checklist

When designing or reviewing an agentic system, cover these components explicitly:

1. Agent fit and autonomy boundary.
2. Model calls and runtime loop.
3. Prompt and instruction contract.
4. Context engineering and retrieval.
5. Tools, tool calling, and MCP surfaces.
6. Structured outputs and parsing.
7. State, memory, persistence, and recovery.
8. Orchestration, handoffs, subagents, and parallelism.
9. Guardrails, approvals, and security controls.
10. Evaluation, benchmarks, and oracle quality.
11. Observability, logs, traces, metrics, and debugging.
12. Cost, latency, rate limits, and token efficiency.

For each component, ask:

- What owns the decision?
- What is the input contract?
- What is the output contract?
- What can fail silently?
- What is logged or traced?
- How is the behavior evaluated?
- What gets simpler if this component is removed?

## 1. Agent Fit And Autonomy Boundary

Sources:

- `anthropic-effective-agents`
- `openai-agents`
- `openai-agent-guide`

Best practices:

- Separate workflows from agents. A workflow follows predefined code paths; an agent dynamically chooses process and tool use.
- Start with the least autonomous design that can meet the success criteria: deterministic code, fixed LLM workflow, router, single tool-using agent, manager-worker, then handoff graph.
- Require clear success criteria, feedback loops, and stop conditions before adding autonomy.
- Choose an agent only when dynamic tool choice, iterative observation, ambiguity handling, or long-running correction is required.
- Keep application code responsible for permissions, persistence, side effects, and final policy checks.
- Do not replace an agent or LLM decision with an unvalidated heuristic just because the model call failed. Retry, degrade explicitly, or ask the user.

Design outputs:

- Agent fit statement.
- Autonomy boundary.
- Stop condition.
- Side-effect policy.
- Simpler alternative rejected and why.

## 2. Model Calls And Runtime Loop

Sources:

- `openai-agents`
- `openai-reasoning`
- `openai-latest-model`

Best practices:

- Model choice is part of the contract. Name the model class, snapshot/version when possible, reasoning effort, temperature or sampling policy, max output, timeout, and retry behavior.
- Distinguish one-shot calls, tool-using calls, and agent loops. Do not hide loops behind a generic "call model" helper with no trace boundary.
- Use capable models to establish a quality baseline, then downshift for cost or latency only after evals prove acceptable behavior.
- Control response length separately from reasoning quality when the provider exposes separate verbosity/output controls.
- Keep loop state explicit: current task, observations, tool results, pending approvals, retry count, and terminal status.
- Treat model upgrades as behavior changes that require eval replay.

Design outputs:

- Model/preset matrix by task type.
- Runtime loop diagram.
- Retry/timeout/fallback policy.
- Upgrade and rollback policy.

## 3. Prompt And Instruction Contract

Sources:

- `anthropic-prompting`
- `openai-prompting`
- `mcp-prompts`

Best practices:

- Prompts must be executable policy, not motivational prose. Keep instructions that affect triggers, decision boundaries, tool choice, output schema, validation, escalation, or stop behavior.
- Put stable role, scope, policies, and output contracts in system/developer instructions; put task data and volatile context in user/runtime messages.
- Include canonical examples for recurring ambiguity, but avoid stuffing every edge case into the prompt.
- Version prompts that affect production behavior; evaluate prompt changes like code changes.
- Prefer explicit output schemas or structured outputs over prose formatting requests when downstream code depends on the result.
- Use MCP prompts or equivalent reusable templates when prompt reuse and discovery are product requirements, not just local convenience.

Design outputs:

- Prompt contract with variables, runtime sources, defaults, and validation.
- No-op filter result.
- Prompt version and eval coverage.

## 4. Context Engineering And Retrieval

Sources:

- `anthropic-context`
- `anthropic-context-cookbook`
- `mcp-resources`
- `langchain-context`

Best practices:

- Context is a budgeted runtime surface, not a document dump. Decide what is pinned, retrieved just-in-time, summarized, compressed, isolated, or omitted.
- Keep context informative but tight: system prompt, tool specs, examples, message history, retrieved resources, and memory all compete for attention.
- Prefer just-in-time retrieval for large or changing corpora; prefer upfront pinned context for small stable policies that must always apply.
- Curate diverse canonical examples instead of long lists of rules.
- Record retrieval queries, selected resources, and excluded high-scoring resources for debuggability.
- Treat summaries as lossy transforms. Define what facts must never be summarized away.
- Use MCP resources or equivalent data-resource abstractions for application-controlled context with stable URIs.

Design outputs:

- Context assembly plan.
- Retrieval and ranking policy.
- Compression/summarization policy.
- Non-lossy fields.
- Context observability requirements.

## 5. Tools, Tool Calling, And MCP Surfaces

Sources:

- `anthropic-tools`
- `anthropic-tool-use`
- `openai-function-calling`
- `mcp-resources`

Best practices:

- Tools are agent-computer interfaces. Names, descriptions, parameters, return values, and errors must be understandable from the tool spec alone.
- Keep tool sets minimal and non-overlapping. If a human cannot reliably decide which tool to use, the agent probably cannot either.
- Namespace tools around real capability boundaries.
- Use schemas, enums, and object structure to make invalid states unrepresentable.
- Do not ask the model to fill arguments already known by application state; inject them in code.
- Combine tool calls that must always happen together.
- Return meaningful context, not raw dumps. Optimize tool responses for token efficiency while preserving facts the agent needs for the next decision.
- Make tool side effects explicit: read-only, idempotent write, irreversible write, external message, money movement, shell command, or privileged operation.
- Validate tool arguments and results in code. Treat partial streamed JSON or malformed tool input as an expected failure mode.

Design outputs:

- Tool catalog with capability boundaries.
- Tool schema and side-effect class.
- Tool selection rules.
- Argument validation and result validation.
- Tool-level tests and evals.

## 6. Structured Outputs And Parsing

Sources:

- `openai-structured-outputs`
- `openai-function-calling`

Best practices:

- Use function/tool calling when the model is selecting actions that application code will execute.
- Use structured output schemas when the model is returning data that downstream code must parse.
- Prefer schema-constrained output over JSON mode when supported; JSON validity alone is not schema adherence.
- Validate every structured result in code and define repair/retry behavior for schema failures.
- Keep user-facing prose separate from machine-facing structured data.

Design outputs:

- Output schemas.
- Parser and validation path.
- Retry/repair policy.
- Downstream compatibility tests.

## 7. State, Memory, Persistence, And Recovery

Sources:

- `openai-sessions`
- `langgraph-persistence`
- `google-adk-memory`
- `google-adk-state`

Best practices:

- Separate conversation history, execution state, business state, user memory, and long-term knowledge.
- Persist enough state to resume after approvals, crashes, retries, and human interruptions.
- Use short-term thread/session memory for conversation continuity; use long-term stores for durable cross-session facts and preferences.
- Define memory write policy: what can be stored, who can see it, retention, deletion, confidence, source, and timestamp.
- Do not let the model silently rewrite business state. Route state mutations through typed application operations.
- Make recovery testable: replay a run from checkpoint and verify the same pending action or final state.

Design outputs:

- State taxonomy.
- Persistence/checkpoint plan.
- Memory read/write policy.
- Recovery and replay tests.

## 8. Orchestration, Handoffs, Subagents, And Parallelism

Sources:

- `openai-agents`
- `openai-agent-guide`
- `cognition-dont-build-multi-agents`
- `cognition-multi-agents-working`

Best practices:

- Prefer one loop owner until there is evidence the single agent is failing because of incompatible tools, overloaded instructions, or ownership boundaries.
- Manager-worker is safer when one agent must own user interaction and synthesize specialist outputs.
- Handoff graphs are justified when ownership truly transfers, not just because a topic changed.
- Parallel read-only agents are useful for independent search, critique, or analysis when one owner reconciles results.
- Parallel writers are high risk. Require shared context, explicit resource ownership, conflict detection, and a single merge/review owner.
- Every handoff needs payload contract, authority boundary, return contract, and trace continuity.

Design outputs:

- Orchestration pattern.
- Handoff contract.
- Subagent context package.
- Write ownership and merge policy.

## 9. Guardrails, Approvals, And Security Controls

Sources:

- `openai-guardrails`
- `langchain-hitl`
- `owasp-prompt-injection`
- `owasp-llm-top-10`

Best practices:

- Place guardrails next to the risk: input guardrails before expensive or unsafe work, tool guardrails around side effects, output guardrails before release.
- Human review is a persisted workflow state, not a vague instruction. Define approve, edit, reject, and respond behaviors where applicable.
- Never rely on prompt instructions alone for auth, authorization, data exfiltration control, or side-effect gating.
- Treat external documents, webpages, logs, and tool results as untrusted inputs that may contain indirect prompt injection.
- Minimize agency for sensitive operations. Require approval for irreversible writes, external messages, financial actions, privileged shell commands, data deletion, and access-control changes.
- Validate model outputs before passing them to interpreters, SQL engines, shells, browsers, ticketing systems, or messaging APIs.

Design outputs:

- Threat model by component.
- Guardrail placement map.
- Approval policy and persisted states.
- Prompt-injection and output-handling tests.

## 10. Evaluation, Benchmarks, And Oracle Quality

Sources:

- `openai-agent-evals`
- `openai-eval-best-practices`
- `anthropic-evals`
- `google-adk-eval`

Best practices:

- Evaluate at multiple layers: final output, tool trajectory, handoff correctness, policy compliance, latency/cost, and recovery behavior.
- Start with traces while debugging; move to repeatable datasets and eval runs once good behavior is defined.
- Use task-specific evals that reflect production distribution, not generic academic metrics alone.
- Include trajectory checks for agents: which tools were called, in what order, with what arguments, and whether required verification steps happened.
- Maintain human agreement for automated graders. Audit the oracle behind expected labels.
- Treat benchmark scores as claims with denominators, excluded cases, model versions, prompt versions, and run dates.

Design outputs:

- Eval objective.
- Dataset and oracle lineage.
- Grading strategy.
- Trace/trajectory checks.
- Regression replay plan.

## 11. Observability, Logs, Traces, Metrics, And Debugging

Sources:

- `openai-tracing`
- `openai-agent-evals`
- `opentelemetry-genai`
- `opentelemetry-semconv`

Best practices:

- Trace the whole workflow, not just model latency. Include model calls, prompts or prompt IDs, model versions, tool calls, tool arguments after redaction, tool results, handoffs, guardrails, approvals, retries, and final output.
- Emit stable IDs: run ID, trace ID, user/session ID, task ID, prompt version, model version, dataset version, tool version, and artifact IDs.
- Separate logs for debugging from metrics for alerting and eval traces for quality analysis.
- Track at least: success/failure, refusal/escalation, tool error rate, schema failure rate, retry count, handoff count, approval count, token usage, latency, cost, and eval/regression scores.
- Redact sensitive content while preserving enough metadata to debug behavior.
- Use trace grading or equivalent review workflows to turn observed failures into eval cases.

Design outputs:

- Trace schema.
- Metric list with owners and alert thresholds.
- Redaction policy.
- Failure-to-eval feedback loop.

## 12. Cost, Latency, Rate Limits, And Token Efficiency

Sources:

- `openai-rate-limits`
- `openai-rate-limit-cookbook`
- `anthropic-caching`
- `anthropic-context`

Best practices:

- Track cost per successful task, not just cost per model call.
- Budget tokens by component: fixed instructions, tools, examples, memory, retrieval, history, reasoning/output, and tool results.
- Use prompt/context caching for stable large context when provider support and cache invalidation semantics fit the workload.
- Use smaller/faster models for guardrails, classifiers, extraction, or routing only after evals prove quality is acceptable.
- Handle rate limits explicitly with queues, backoff, retry-after handling, and user-visible degradation paths.
- Avoid adding tools or context that increase every run's token cost unless evals show material quality improvement.

Design outputs:

- Token and cost budget.
- Cache strategy.
- Rate-limit and retry plan.
- Latency SLO and degradation policy.

## Cross-Component Failure Modes

- Tool overlap creates ambiguous calls and inconsistent trajectories.
- Too much context dilutes important instructions and facts.
- Unvalidated structured output breaks downstream systems.
- Hidden retries and fallback models corrupt metrics.
- Multi-agent parallel writes fragment implicit decisions.
- Guardrails only at the top level miss nested tool calls.
- Logs without prompt/model/tool versions cannot explain regressions.
- Evals without oracle audits reward the wrong behavior.

## Minimum Design Artifact

For any serious agentic system, produce:

- Architecture: workflow/agent pattern and loop owner.
- Model: model/version, parameters, fallback, and upgrade policy.
- Prompt: versioned instruction contract and no-op audit.
- Context: assembly, retrieval, memory, compression, and non-lossy facts.
- Tools: catalog, schemas, side effects, validation, and tests.
- State: persistence, recovery, approvals, and memory policy.
- Security: prompt-injection, output-handling, permissions, and human review controls.
- Evals: datasets, oracle, trajectory checks, and regression replay.
- Observability: traces, logs, metrics, IDs, redaction, and dashboards.
- Operations: cost budget, latency SLO, rate limits, and failure modes.
