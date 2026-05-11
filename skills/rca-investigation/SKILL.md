---
name: rca-investigation
description: This skill should be used when the user asks for "RCA", "root cause analysis", "wide and deep RCA", "incident analysis", "workflow failure analysis", "why did this fail", "investigate a failed run", "OOM analysis", "API limit analysis", "restart analysis", "stale endpoint analysis", or asks to trace logs, metrics, DB artifacts, code paths, and systemic fixes without jumping to conclusions.
version: 1.1.0
---

# RCA Investigation

Use this skill for wide and deep root-cause analysis. Do not jump to a root cause early. Start with competing hypotheses, define what would prove or weaken each one, and identify the artifact type needed: logs, metrics, DB, code, config, or runtime trace.

## Start With Competing Hypotheses

List 3-5 plausible hypotheses before investigating.

For each hypothesis, state:

- what evidence would prove it
- what evidence would weaken it
- what artifact type is needed: logs, metrics, DB, code, config, or runtime trace

Do not infer cause from timestamp adjacency alone.

## 1. Identify The Exact Incident

Capture the incident identifiers that exist for the system under investigation:

- workflow id
- repo/PR
- run id, job id, sandbox id, runner id, pod, namespace, VM, host, or service instance
- failing timestamp
- artifact paths, especially DB, logs, traces, build outputs, or exported metrics

If any of these are unknown, list them under `Still unknown` and state how to find them.

## 2. Build A Timeline

Query logs before, during, and after the failure.

Requirements:

- capture exact timestamps
- separate symptoms from causes
- compare pre-failure, failure-window, and post-failure evidence
- avoid assigning causality from timestamps alone
- for every paired event A → B, explicitly state the hypothesized causal direction and what would disconfirm it. Adjacency does not tell you which caused which, or whether both were caused by an upstream C.
- cite **recovery signals adjacent to failure signals**. A failure that recovers without intervention has a different cause than a failure that persists. Reading only the failing log lines biases the story toward "persistent infra failure."

## 2a. Verify Identity Continuity

Before claiming an entity (process, runner, container, pod, VM, connection, IP, file, request, workflow run, service instance) is "still alive", "still the same", or "changed", pin the claim to a stable identifier — not to a logical name.

Names persist across recreation. Identities do not. Common traps:

- A pod's *name* and *UID* can survive while its **container instance ID, network namespace, and IP all change** (e.g., when the CRI pod-sandbox / pause container is recreated).
- A CI job name can stay the same while the **run id, attempt id, runner id, workspace path, and cache key** change.
- A VM or host label can stay the same while the underlying **instance id, boot id, image, or attached volume** changes.
- A service can keep its DNS name while its backing endpoints are entirely replaced.
- A connection can keep the same destination IP string while pointing at a different physical endpoint after a route change.
- A file can keep its path while its inode (and contents) are replaced atomically.

For each entity you reason about, write down the **identity primitive** you're tracking:

- process: PID + start_time (PIDs are reused)
- workflow/job: run id + attempt id + job id + runner id
- CI workspace/cache: workspace path + commit SHA + cache key + cache version
- VM/host: instance id + boot id + image id
- container: containerID (containerd/CRI ID), not container name
- pod: pod UID + sandbox-container/pause-container ID + current pod IP
- network endpoint: endpoint id when available + current IP at the failure timestamp (not the IP from a provisioning log earlier)
- session/connection: 5-tuple + cookie/session ID, not just remote name
- DB row: PK + version/etag, not search predicate

If you only have a name-level signal (e.g., "logs still flowing from pod X"), say so explicitly and note that this is consistent with both "same instance" and "recreated instance with same name." Then go look for the identity primitive before relying on the claim.

## 3. Prove The Failure Mode

Match the alleged failure mode to hard evidence:

- If OOM: find kernel/cgroup OOM logs and memory metrics.
- If API limit: find the exact provider error.
- If restart: find process, runner, VM, pod, or container lifecycle events.
- If stale endpoint: compare old/new IP or endpoint values.

Do not confuse token limit with OOM. Do not confuse cache existence with cache causality.

### 3a. Scope Sweep — query every layer the signal could live in

A given event-type emits at multiple scopes. **Empty result at one scope is not absence at the others.** Before concluding "no evidence of X," enumerate the scopes where X plausibly emits and query each.

Common signal-to-scope mapping. Adapt to the platform: GitHub Actions, Buildkite, Kubernetes, Nomad, systemd, hosted runners, VMs, serverless jobs, or local sandboxes.

- **Process / container death (OOM, signal, crash)**
  - application stdout/stderr
  - runner/worker/job executor log
  - process supervisor events (`systemd`, launchd, job runner, queue worker)
  - container runtime events when applicable (containerd `TaskOOM`, `TaskExit` with exit_status; CRI `ContainerStatus.Reason`)
  - host/kernel log when applicable (kernel cgroup OOM: `"Memory cgroup out of memory"`, `"Killed process N (...)"`)
  - orchestration events when applicable (pod/job/task object events, backoff, eviction, preemption)
  - memory metrics (RSS, cgroup memory, working set, heap, runtime allocator metrics)
- **Network unreachability**
  - client-side error type (connect refused vs i/o timeout vs DNS failure vs TLS)
  - DNS resolution at the failure timestamp
  - endpoint/service registry state at the failure time
  - load balancer, proxy, gateway, or service mesh logs
  - CNI/dataplane logs when applicable
  - VPC/firewall/security-group audit logs in the failure window
  - health/readiness checks from the source and destination side
- **Authentication / authorization failure**
  - server-side audit log
  - identity provider log
  - token issuance log
  - client SDK retry pattern
- **CI / workflow artifact failure**
  - workflow run metadata and attempt number
  - runner assignment and runner image/version
  - checkout commit SHA and merge ref
  - cache restore/save logs and cache key
  - artifact upload/download logs
  - step-level exit code and shell trace

Record explicitly which scopes you checked, which you did not, and your confidence that absence at the checked scopes generalizes.

### 3b. Runtime / platform check

Before reasoning about failure semantics, identify the execution substrate:

- CI runner type, runner image, hosted vs self-hosted, and retry/attempt number
- process supervisor or job executor
- container runtime when applicable (runc, runsc/gVisor, kata, firecracker, Windows process isolation)
- orchestration platform when applicable (Kubernetes, Nomad, ECS, systemd, serverless job platform)
- network/dataplane plugin when applicable (CNI, service mesh, load balancer, VPC/firewall)
- whether hosts/runners are spot/preemptible/auto-provisioned
- whether the workload is on a shared kernel or isolated kernel

Failure semantics differ. Example: under gVisor, when the kernel OOM-kills the runsc sandbox process, Kubernetes may not mark `Reason=OOMKilled` on the in-container app; the proof moves to the node kernel log and container runtime events. On a hosted CI runner, the proof may instead live in runner diagnostics, step exit codes, hosted-runner service logs, or provider status events. Do not apply one platform's failure semantics to another platform without checking.

## 4. Inspect Persistent Artifacts

Locate or download DBs and artifacts.

Process:

1. Inspect schema first.
2. Write explicit SQL queries.
3. Compare against known-good runs.
4. Quantify magnitude, not just presence.

Use DB evidence only for what it actually proves.

## 5. Trace The Code Path

Find:

- where the bad input enters
- where filtering should have happened
- where memory, network, or LLM payload is materialized
- whether behavior is full build, partial build, or downstream scan behavior

Do not assume a filter ran because code exists. Prove the filter is on the active path and executed for the incident.

## 6. Separate Proof Levels

Use these labels:

```text
Proven by logs:
- ...

Proven by metrics:
- ...

Proven by DB:
- ...

Proven by code:
- ...

Inferred:
- ...

Still unknown:
- ...

Scopes searched (and not searched):
- searched: [resource types / log streams / metric series]
- not searched: [...]
- confidence that absence at the searched scopes implies overall absence: [low / medium / high] — and why
```

## 7. Fight Premature Conclusions

Before giving RCA, ask:

- Could this be only a downstream symptom?
- Did I compare against a normal run?
- Did I prove the filter actually ran?
- Did I confuse token limit with OOM?
- Did I confuse cache existence with cache causality?
- Did I prove exact heap allocation, or only the strongest mechanism?
- Did I prove the failing entity is the same physical instance, not just the same name? (identity vs. name)
- Did I cite recovering signals adjacent to failing signals, or only the failing ones?
- For each "A caused B" in my narrative, have I considered "B caused A" and "C caused both"?
- For infra-failure claims (runner, scheduler, storage, network, runtime, provider): did I read the component's own logs or provider events first?
- Did I treat absence-at-one-scope as absence overall, or did I scope-sweep?
- Does my conclusion fit only the pattern, or has it actually disproven the rival hypotheses?

If any answer is unresolved, preserve uncertainty in the final RCA.

### 7a. Adversarial Check — steelman the opposite

Before naming a root cause, force one explicit adversarial pass:

1. State the strongest evidence **against** the leading hypothesis. If you cannot produce any, you have not investigated enough.
2. State at least one alternative hypothesis that fits the **same** observed evidence. Identify the single piece of evidence that would distinguish them, and go fetch it.
3. For any infrastructure-failure conclusion (runner, kernel, scheduler, runtime, network, storage, cloud provider): the **null hypothesis is "the infrastructure worked correctly."** Pattern-fit is not sufficient — you must read the component's own logs or provider events and show that they record the failure. If they record correct operation, the failure lives elsewhere.
4. For any "stale state" conclusion (stale IP, stale cache, stale DNS): identify both the **moment the state went stale** (an upstream cause) and the **client behavior that kept using the stale value** (a downstream cause). Both halves are root causes; do not stop at one.
5. If the symptom set is "X became unreachable and stayed unreachable", ask explicitly: was X *killed/stopped/replaced* or was the *path to X* broken? The two require different evidence:
   - X killed → process exit / OOM / crash signals at X's host
   - path broken → DNS / routing / firewall / endpoint-table / proxy / dataplane signals on the path
   Inverting these is the most common direction-of-causality error.

## 8. Recommend Systemic Fixes

Avoid symptom fixes like "increase memory" unless paired with root fixes.

For each fix, say:

- which failure boundary it addresses
- what signal it might lose
- how to report that signal instead of hiding it
- how to verify the fix with logs, DB, or metrics

## Final Answer Format

Use:

```text
Root cause:
- One sentence.

Timeline:
- ...

Strongest evidence:
- ...

What is inferred vs proven:
- ...

Systemic fix:
- ...

Gotchas:
- ...

Exact commands/queries used:
- ...
```

If a root cause is not proven, do not force one. State the strongest proven failure mode and what evidence is still needed.
