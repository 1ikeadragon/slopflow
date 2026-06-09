---
name: rca-investigation
description: Cumulative, proof-driven root-cause analysis for incidents, failed runs, regressions, OOMs, API-limit errors, restarts, and stale-state failures. Integrates runtime evidence with competing hypotheses, code/config/git tracing, proof levels, and systemic fixes. Use when the user asks for an RCA, "why did this fail", or incident analysis. When the input is a workflow/run id, cloud logs, artifacts, or cache behavior, run workflow-rca first to collect the runtime evidence packet, then continue here.
version: 2.0.0
---

# RCA Investigation

Use this skill for wide and deep cumulative root-cause analysis. Do not jump to a root cause early. Classify the input, collect runtime evidence (via `workflow-rca` for workflow-centric incidents), then integrate logs, metrics, DB artifacts, code paths, config, and git history into one proof-driven RCA.

Deep evidence playbooks live in `references/evidence-playbooks.md`. Read the relevant section when the investigation hits that problem:

- **Identity Continuity** — before claiming an entity is "still the same" or "changed" (pods, runners, VMs, connections, files).
- **Scope Sweep** — before concluding "no evidence of X"; enumerates the scopes each failure class emits at.
- **Runtime / Platform Check** — before interpreting failure semantics on an unfamiliar substrate (gVisor, hosted runners, orchestrators).
- **Decomposition Before Attribution** — before naming a cause for an aggregate signal (memory, latency, error rate, CPU, backlog).
- **Artifact Location Playbook** — before hunting for run metadata, logs, DBs, traces, or cache objects.

## 0. Classify The Input

Before forming hypotheses, identify what kind of evidence or identifier the user gave you. Do not assume a repo issue, workflow URL, pod name, or opaque string all imply the same investigation path.

```text
Input classification:
- input type: workflow id / run id / CI run URL / repo+PR / pod+namespace / log excerpt / DB artifact path / timestamp only / mixed / unknown
- parsed identifiers:
- missing identifiers:
- likely system:
- workflow-rca needed: yes / no / uncertain
- code/config/git paths to trace:
- first commands or queries:
```

If the input is ambiguous, search for it literally in likely runtime logs/artifacts or repository metadata before assigning meaning. If it is a workflow/run id, cloud-log question, artifact question, or cache question, use `workflow-rca` first or in parallel, then return here with its evidence packet.

## 1. Start With Competing Hypotheses

List 3-5 plausible hypotheses before investigating. For each: what evidence would prove it, what would weaken it, and what artifact type is needed (logs, metrics, DB, code, config, runtime trace). Do not infer cause from timestamp adjacency alone.

## 2. Identify The Exact Incident

Capture the identifiers that exist for this system: workflow/run/job id, repo/PR, sandbox/pod/namespace/host/instance, failing timestamp, and artifact paths (DBs, logs, traces, build outputs, exported metrics). List unknown identifiers under `Still unknown` with how to find them.

## 3. Build A Timeline

Query logs before, during, and after the failure.

- Capture exact timestamps; separate symptoms from causes.
- For every paired event A → B, state the hypothesized causal direction and what would disconfirm it. Adjacency does not tell you which caused which, or whether an upstream C caused both.
- Cite recovery signals adjacent to failure signals. A failure that recovers without intervention has a different cause than one that persists; reading only the failing lines biases toward "persistent infra failure".
- Before claiming an entity persisted or changed across the timeline, apply the Identity Continuity playbook.

## 4. Prove The Failure Mode

Match the alleged failure mode to hard evidence:

- OOM → kernel/cgroup OOM logs and memory metrics. Do not confuse token limits with OOM.
- API limit → the exact provider error.
- Restart → process, runner, VM, pod, or container lifecycle events.
- Stale endpoint → old/new IP or endpoint values compared.

Before concluding absence of evidence, run the Scope Sweep playbook. Before interpreting platform-specific signals, run the Runtime / Platform Check. Before attributing an aggregate signal, run Decomposition Before Attribution. Do not confuse cache existence with cache causality.

## 5. Verify The Production Path

Before claiming a code location is "the bug" or recommending a fix there, prove the path is on the live execution path for the incident. Code existence is not execution proof; search matches are not execution proof. Three lines of evidence are required:

1. **Entrypoint registration**: the code is wired into the runtime entrypoint (worker registration, router attachment, scheduler/cron registration, queue subscription, CI step reference).
2. **Invocation chain**: a caller, route, queue, or step actually reaches this code with the same identifiers seen in the incident.
3. **Runtime trace**: logs, metrics, traces, or audit records from the incident window show this exact code ran.

Check for negation: feature flags, config gates, environment branches, recent replacement, sibling v2/v3 modules, string-based dispatch, conditional imports, build-time substitution. State in the RCA which of the three lines were verified; if any is missing, the fix may target dead code or a downstream symptom.

## 6. Inspect Persistent Artifacts

Locate DBs and artifacts using the Artifact Location Playbook. Then: inspect schema first, write explicit queries, compare against known-good runs, and quantify magnitude rather than just presence. Use DB evidence only for what it actually proves.

## 7. Trace The Code Path

Find where the bad input enters, where filtering should have happened, and where memory, network, or payload is materialized. Do not assume a filter ran because code exists; prove it is on the active path and executed for the incident.

## 8. Separate Proof Levels

```text
Proven by logs:
Proven by metrics:
Proven by DB:
Proven by code:
Inferred:
Still unknown:

Scopes searched (and not searched):
- searched:
- not searched:
- confidence that absence at the searched scopes implies overall absence: low / medium / high, and why
```

## 9. Fight Premature Conclusions

Before giving the RCA, check:

- Could this be only a downstream symptom? Did I compare against a normal run?
- Did I prove the filter actually ran, the entity is the same physical instance, and the failure mode (not just a lookalike)?
- For each "A caused B", have I considered "B caused A" and "C caused both"?
- Did I treat absence-at-one-scope as absence overall?
- Does my conclusion fit only the pattern, or has it disproven the rival hypotheses?

Then force one adversarial pass:

1. State the strongest evidence **against** the leading hypothesis. If you cannot produce any, you have not investigated enough.
2. State at least one alternative hypothesis that fits the same evidence; identify the single piece of evidence that distinguishes them, and fetch it.
3. For any infrastructure-failure conclusion, the null hypothesis is "the infrastructure worked correctly". Read the component's own logs or provider events; if they record correct operation, the failure lives elsewhere.
4. For any "stale state" conclusion, identify both the moment the state went stale (upstream cause) and the client behavior that kept using the stale value (downstream cause). Both are root causes.
5. If "X became unreachable and stayed unreachable": was X killed/replaced, or was the path to X broken? Killed → exit/OOM/crash signals at X's host. Path broken → DNS/routing/firewall/endpoint/proxy signals on the path. Inverting these is the most common direction-of-causality error.

If anything is unresolved, preserve the uncertainty in the final RCA.

## 10. Recommend Systemic Fixes

Avoid symptom fixes like "increase memory" unless paired with root fixes. For each fix, say which failure boundary it addresses, what signal it might lose, how to report that signal instead of hiding it, and how to verify the fix with logs, DB, or metrics.

## Final Answer Format

```text
Root cause:
- One sentence.

Timeline:
Strongest evidence:
What is inferred vs proven:
Systemic fix:
Gotchas:
Exact commands/queries used:
```

If a root cause is not proven, do not force one. State the strongest proven failure mode and what evidence is still needed.
