---
name: workflow-rca
description: Use when the user asks for workflow/runtime RCA, Temporal workflow ids, CI/job run ids, GCP Cloud Logging investigation, GCS artifact lookup, workflow DB artifacts such as call_graph.db, cache hit/miss behavior, TTFT/429 issues, duplicate finding lineage, worker behavior, or asks why a workflow failed, slowed down, retried, did not resolve, loaded cache, or built fresh. Use with rca-investigation for cumulative code-level root cause proof.
version: 1.0.0
---

# Workflow RCA

Use this skill for workflow-centric runtime evidence collection. It is designed to work with `rca-investigation`: this skill gathers and proves what happened at the workflow/runtime/artifact layer; `rca-investigation` integrates that evidence with code, config, DB interpretation, git history, and systemic fixes.

Do not make this skill project-specific. Do not assume a default GCP project, bucket, namespace, workflow type, table schema, or cache convention unless the user, runtime logs, deployment config, or repository code proves it.

## Core Rules

- Start from the exact workflow id, run id, job id, PR number, commit, finding id, pod, namespace, timestamp, or artifact path the user gave.
- Always say how you found each fact, with the command/query/log/artifact that proves it.
- Separate proven runtime facts from inferred workflow behavior.
- If the user did not explicitly ask to download a DB or artifact, find the object path and metadata first, then ask before downloading.
- For latest/current status, trust live logs and provider APIs over memory or stale artifacts.
- Empty results from one project, log name, namespace, or time window do not prove absence.

## 1. Classify The Workflow Input

Use this structure first:

```text
Workflow input classification:
- input type: Temporal workflow id / Temporal run id / CI run URL / job id / pod+namespace / GCS object / DB path / finding id / cache key / log excerpt / timestamp only / mixed / unknown
- parsed identifiers:
- missing identifiers:
- likely platform: Temporal / CI / Kubernetes worker / batch job / serverless job / unknown
- likely artifact classes: logs / GCS objects / DB / metrics / traces / code config / git history
- first lookup path:
```

If the identifier is ambiguous, search for the literal string in logs/artifacts before assigning meaning.

## 2. GCP And Cloud Logging Workflow

When GCP is plausible, verify identity and available logging surface before widening slow or empty queries:

```sh
gcloud config list --format='text(core.project,account)'
gcloud auth list --filter=status:ACTIVE
gcloud projects list
gcloud logging logs list --project="<project>"
```

Project selection rules:

- Prefer an explicit project from the user.
- Next prefer project values from deployment config, workflow metadata, artifact paths, or logs.
- Treat the local active `gcloud` project as a hint, not proof.
- If no project is known, state that log lookup is blocked and show the exact project-dependent command to run.

Minimum literal workflow-id log search:

```sh
PROJECT="<project>"
WORKFLOW_ID="<workflow-id>"
gcloud logging read "\"${WORKFLOW_ID}\"" --project="$PROJECT" --freshness=14d --limit=200 --format=json
gcloud logging read "\"${WORKFLOW_ID}\"" --project="$PROJECT" --freshness=14d --limit=200 --format='table(timestamp,resource.type,resource.labels.namespace_name,resource.labels.pod_name,resource.labels.container_name,severity,logName)'
```

If a failure window is known, use timestamp bounds instead of broad freshness:

```sh
gcloud logging read "\"${WORKFLOW_ID}\" AND timestamp>=\"<start-iso>\" AND timestamp<=\"<end-iso>\"" --project="$PROJECT" --limit=500 --format=json
```

If logs reveal namespace, pod, worker service, task queue, run id, activity, or request id, pivot into narrower queries:

```sh
gcloud logging read "\"${WORKFLOW_ID}\" AND resource.labels.namespace_name=\"<namespace>\"" --project="$PROJECT" --freshness=14d --limit=500 --format=json
gcloud logging read "\"<run-id>\" OR \"${WORKFLOW_ID}\"" --project="$PROJECT" --freshness=14d --limit=500 --format=json
gcloud logging read "\"<task-queue>\" AND (\"error\" OR \"failed\" OR \"timeout\" OR \"panic\" OR \"exception\" OR \"429\")" --project="$PROJECT" --freshness=14d --limit=500 --format=json
```

If `gcloud` is flaky but auth works, use the Cloud Logging API directly:

```sh
TOKEN="$(gcloud auth print-access-token)"
curl -sS -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" \
  "https://logging.googleapis.com/v2/entries:list" \
  -d '{"resourceNames":["projects/<project>"],"filter":"\"<workflow-id>\"","pageSize":200}'
```

## 3. Temporal Workflow Evidence

For Temporal workflows, extract these fields from logs, Temporal metadata, or worker output before declaring the incident identified:

- namespace
- workflow id
- run id
- workflow type
- task queue
- worker service/deployment
- first observed timestamp
- first failure timestamp
- last retry/recovery timestamp
- terminal state if known
- exact error type and message
- activity name, workflow task phase, or child workflow if present
- pod/container/service instance that emitted the decisive log line

Distinguish:

- retryable activity failure
- workflow task failure
- child workflow failure
- worker crash/restart
- external API limit or timeout
- cache/artifact load failure
- downstream scanner or validation failure

## 4. Build A Runtime Timeline

Pull enough logs before, during, and after the failure to answer:

- current phase or terminal state
- cache hit, parent hit, miss, bypass, or rebuild
- major activity durations
- worker/pod/container identity
- error signatures such as `429`, `RESOURCE_EXHAUSTED`, `TTFTTimeoutError`, config failures, checkpoint errors, upload/download failures, DB errors, and provider timeouts
- recovery signal or lack of recovery

Separate symptoms from causes. Do not infer root cause from timestamp adjacency alone.

Use this format:

```text
Workflow timeline:
- <timestamp> | <source> | <event> | proof:
- <timestamp> | <source> | <event> | proof:

Symptoms:
- ...

Candidate causes:
- ...

Still unknown:
- ...
```

## 5. GCS And Artifact Handling

Trace object paths from logs, workflow metadata, config, or code. Do not guess bucket layout from memory.

Before downloading, confirm metadata:

```sh
gcloud storage objects describe "gs://<bucket>/<object>"
gcloud storage ls -l "gs://<bucket>/<prefix>/**"
```

If `gsutil` is the available tool:

```sh
gsutil ls -L "gs://<bucket>/<object>"
gsutil ls -l "gs://<bucket>/<prefix>/**"
```

Record:

- object path
- size
- generation/metageneration when available
- updated timestamp
- content type if useful
- whether multiple writes/overwrites happened during the run
- whether the object timestamp aligns with the workflow timeline

Ask before downloading unless the user explicitly requested download/DB inspection.

## 6. SQLite / DB Artifact Inspection

When the user approves DB download or provides a local DB path, inspect schema first:

```sh
sqlite3 "<db-path>" ".tables"
sqlite3 "<db-path>" ".schema"
sqlite3 "<db-path>" "SELECT name, type FROM sqlite_master ORDER BY type, name;"
```

For finding/call-graph style DBs, query only tables that exist. Useful checks often include:

```sql
SELECT COUNT(*) FROM findings;
SELECT hidden, false_positive, COUNT(*) FROM findings GROUP BY hidden, false_positive;
SELECT created_by, validated_by, COUNT(*) FROM findings GROUP BY created_by, validated_by;
SELECT source_finding_id, COUNT(*) FROM findings WHERE source_finding_id IS NOT NULL GROUP BY source_finding_id ORDER BY COUNT(*) DESC;
SELECT * FROM finding_associated LIMIT 20;
SELECT * FROM finding_tags LIMIT 20;
```

For duplicate or lineage questions:

- treat each row as a pipeline artifact, not automatically the final reportable result
- trace who created each row
- identify hidden duplicate rows, false-positive rows, low-leverage rows, and surviving rows separately
- inspect stored metadata/judge reasoning instead of guessing

## 7. Cache And Rebuild Proof

Do not say "cache hit" unless logs prove the specific cache state:

- exact hit
- parent hit
- miss
- bypass
- stale object reuse
- rebuild/fresh generation
- restore failure
- save/upload failure

If asked how to evict or bypass cache, separate:

- bypass for one run
- namespace or key isolation
- actual object deletion
- cache TTL or retention change

## 8. Workflow Evidence Packet

End workflow evidence collection with a packet that `rca-investigation` can consume:

```text
Workflow evidence packet:
- identifiers:
- project/account/log scope:
- runtime platform:
- timeline:
- decisive log evidence:
- artifacts found:
- artifacts not downloaded:
- DB paths inspected:
- cache state:
- errors and provider signals:
- recovery signals:
- commands/queries used:
- proven:
- inferred:
- still unknown:
- recommended code/config paths to inspect next:
```

If a full RCA is requested, hand this packet to `rca-investigation` and continue with code/config/git-history proof before naming a root cause.
