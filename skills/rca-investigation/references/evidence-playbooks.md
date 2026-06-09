# RCA Evidence Playbooks

Deep playbooks for specific evidence problems. Read the section you need; each is self-contained.

## Identity Continuity

Before claiming an entity (process, runner, container, pod, VM, connection, IP, file, request, workflow run, service instance) is "still alive", "still the same", or "changed", pin the claim to a stable identifier, not to a logical name. Names persist across recreation; identities do not.

Common traps:

- A pod's *name* and *UID* can survive while its container instance ID, network namespace, and IP all change (e.g., when the CRI pod-sandbox / pause container is recreated).
- A CI job name can stay the same while the run id, attempt id, runner id, workspace path, and cache key change.
- A VM or host label can stay the same while the underlying instance id, boot id, image, or attached volume changes.
- A service can keep its DNS name while its backing endpoints are entirely replaced.
- A connection can keep the same destination IP string while pointing at a different physical endpoint after a route change.
- A file can keep its path while its inode (and contents) are replaced atomically.

For each entity you reason about, write down the identity primitive you are tracking:

- process: PID + start_time (PIDs are reused)
- workflow/job: run id + attempt id + job id + runner id
- CI workspace/cache: workspace path + commit SHA + cache key + cache version
- VM/host: instance id + boot id + image id
- container: containerID (containerd/CRI ID), not container name
- pod: pod UID + sandbox-container/pause-container ID + current pod IP
- network endpoint: endpoint id when available + current IP at the failure timestamp (not the IP from a provisioning log earlier)
- session/connection: 5-tuple + cookie/session ID, not just remote name
- DB row: PK + version/etag, not search predicate

If you only have a name-level signal (e.g., "logs still flowing from pod X"), say so explicitly and note that it is consistent with both "same instance" and "recreated instance with same name". Then find the identity primitive before relying on the claim.

## Scope Sweep

A given event-type emits at multiple scopes. Empty result at one scope is not absence at the others. Before concluding "no evidence of X", enumerate the scopes where X plausibly emits and query each. Adapt to the platform: GitHub Actions, Buildkite, Kubernetes, Nomad, systemd, hosted runners, VMs, serverless jobs, or local sandboxes.

- **Process / container death (OOM, signal, crash)**
  - application stdout/stderr
  - runner/worker/job executor log
  - process supervisor events (systemd, launchd, job runner, queue worker)
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

## Runtime / Platform Check

Before reasoning about failure semantics, identify the execution substrate:

- CI runner type, runner image, hosted vs self-hosted, and retry/attempt number
- process supervisor or job executor
- container runtime when applicable (runc, runsc/gVisor, kata, firecracker, Windows process isolation)
- orchestration platform when applicable (Kubernetes, Nomad, ECS, systemd, serverless job platform)
- network/dataplane plugin when applicable (CNI, service mesh, load balancer, VPC/firewall)
- whether hosts/runners are spot/preemptible/auto-provisioned
- whether the workload is on a shared kernel or isolated kernel

Failure semantics differ by substrate. Example: under gVisor, when the kernel OOM-kills the runsc sandbox process, Kubernetes may not mark `Reason=OOMKilled` on the in-container app; the proof moves to the node kernel log and container runtime events. On a hosted CI runner, the proof may instead live in runner diagnostics, step exit codes, hosted-runner service logs, or provider status events. Do not apply one platform's failure semantics to another without checking.

## Decomposition Before Attribution

When observing a single aggregate signal (memory at limit, latency spike, error rate, CPU saturation, queue backlog), decompose the aggregate into its parts before naming a cause. Plausible-mechanism narratives are easy to invent and hard to falsify; measured decompositions are not.

Decomposition primitives by signal:

- **Memory**: process RSS/PSS, heap, anon memory, file/page cache, shmem, slab/kernel memory, cgroup/container memory, runtime allocator metrics. If the metric provider does not export the breakdown, collect it from the host, runtime, process, or container where possible.
- **Latency**: trace breakdown by span or phase: queueing, network, DNS/TLS, database, cache, LLM/provider call, framework overhead, serialization, artifact upload/download.
- **Error rate**: classify by error class: 4xx, 5xx, timeout, connection refused, DNS failure, TLS failure, rate limit, auth failure, validation failure.
- **CPU saturation**: user time, kernel time, scheduler latency, throttling counters, steal time, GC/runtime time.
- **Queue/backlog**: enqueue rate, dequeue rate, worker concurrency, retry count, poison-message rate, lock contention.
- **Artifact/storage growth**: file count, byte size, compression ratio, duplicate entries, cache hit/miss split, upload/download timing.

Rule: pattern-fit produces hypotheses; decomposition produces conclusions. If a statement depends on mechanism but the mechanism was not measured, label it: "plausibly X, mechanism inferred but not directly measured." Do not state "X caused it" without measuring X's contribution or showing direct runtime evidence.

Common pitfalls:

- quoting a process-level statistic as a job/container/host-level cause when multiple processes contribute
- using a lower-bound metric as if it were an upper bound
- applying memory-accounting assumptions from one runtime to another
- attributing growth to allocator arenas, memfd retention, page cache, cache bloat, or artifact volume without measuring that layer's actual share
- confusing instantaneous metrics with high-water marks
- querying a parent cgroup/container/job group when the real data is at a child
- aggregating over a coarse window that hides sub-window peaks
- calling a bounded oscillating time series "monotonic" without checking point-to-point deltas

When the breakdown is not available, say so directly. "I cannot decompose this aggregate further from available metrics; the dominant contributor is plausibly Y but unmeasured" is acceptable. "The dominant contributor is Y" without measurement is over-claiming.

## Artifact Location Playbook

Do not start with repo-wide grep if the platform has stable artifact conventions. First identify where each artifact class should live for this system, then verify the convention from code/config/runtime metadata.

Build an artifact map:

```text
Artifact map:
- workflow/run metadata: source, key/id, timestamp field
- logs: source, query
- DB / state snapshot: source, object key or path, schema/version
- traces: source, trace/span identifiers
- metrics: source, series names and labels
- build/cache/artifacts: source, key/path, retention policy
```

For workflow or CI failures, resolve run identity before artifact identity:

1. Get run id, attempt id, job id, commit SHA, branch/ref, workflow name, runner id, and trigger event.
2. Use workflow metadata or provider API to find artifact names and retention state.
3. Compare artifact creation/upload timestamps to the failure window.
4. If a cache was involved, distinguish cache hit, cache miss, cache restore failure, cache save failure, and stale cache reuse.
5. For DB/state artifacts, inspect schema before querying and record the artifact version.

For service or distributed-system failures:

1. Resolve service name to concrete endpoint identity at the failure timestamp.
2. Locate logs at client, server, proxy/gateway, scheduler/orchestrator, and infrastructure/provider scopes.
3. Locate metrics using stable labels from runtime identity, not only human-readable names.
4. Link traces by trace id/span id/request id where possible.
5. Compare against a known-good run or normal time window.

For object stores or artifact buckets:

- derive object keys from source code/config only after proving that source is on the production path
- verify object existence, size, mtime/generation, checksum/etag, and content type
- distinguish "artifact absent", "artifact exists but stale", "artifact exists but wrong run", and "artifact exists but unreadable"
- avoid treating cache existence as cache causality

Treat documented paths as hints, not contracts. Re-verify against current code/config/runtime metadata before relying on them.
