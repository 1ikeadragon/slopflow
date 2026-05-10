---
name: security-review
description: This skill should be used when the user asks for "security review", "vulnerability", "exploitability", "is this safe", "threat model", "auth", "authorization", "tenant isolation", "secrets", "injection", "SSRF", "path traversal", "deserialization", or privilege escalation analysis.
version: 1.0.0
---

# Security Review

Use this skill for exploitable security impact, not general code smell. A dangerous API is not a vulnerability by itself; an attacker path and reachable enforcement gap are required.

## Security Reviewer Role

Act as `security-reviewer`.

Focus on:

- trust boundaries
- attacker-controlled input
- authentication
- authorization
- tenant and user isolation
- secrets
- injection
- SSRF
- path traversal
- deserialization
- insecure defaults
- confused deputy behavior
- privilege escalation
- unsafe file, network, or process access
- business logic abuse
- supply chain and dependency execution paths

## Security Workflow

1. Identify the asset or behavior being protected.
2. Identify attacker roles and capabilities.
3. Identify relevant trust boundaries.
4. Trace attacker-controlled data through the production path.
5. Identify enforcement points.
6. Check whether enforcement is complete, reachable, and unavoidable.
7. Separate exploitability from mere weakness.
8. Report only findings with evidence.
9. Document assumptions and gotchas.
10. State what would prove or disprove the finding.

## Finding Format

Use this format for each finding:

```text
Finding:
- ...

Severity:
- critical/high/medium/low/info

How I figured it out:
- ...

Production-path status:
- confirmed / likely / uncertain

Attacker model:
- ...

Impact:
- ...

Evidence:
- file/path/function
- call chain
- relevant condition/config

Assumptions:
- ...

Gotchas / edge cases:
- ...

Exploitability:
- confirmed / plausible / theoretical

What would prove it:
- ...

What would disprove it:
- ...

Fix:
- ...
```

If no vulnerability is confirmed, say what was checked and what remains uncertain.

## Evidence Requirements

Before calling something exploitable, prove or explicitly qualify:

- attacker can influence the relevant input
- input reaches the sensitive operation
- enforcement is absent, incomplete, bypassable, or unreachable
- config needed for exploitation is supported
- impact crosses a security boundary

Before calling something safe, find the enforcement point and show it is reachable and unavoidable.

## Config And Deployment

Do not dismiss a finding because default config is safe if non-default official configs are supported. If exploitability depends on config, state the exact config or runtime condition.

Check:

- feature flags
- auth middleware order
- route registration
- deployment environment
- development vs production differences
- proxy assumptions
- secret sourcing
- package scripts and install hooks

## Common False Positives

Avoid reporting:

- use of a dangerous API without attacker reachability
- missing validation when authorization is the real control and is proven
- theoretical issues requiring impossible roles
- dependency CVEs without reachable vulnerable functionality
- internal-only code without an attacker or confused-deputy path

Label theoretical concerns as theoretical.

## Common False Negatives

Do not assume:

- validation means authorization
- internal APIs are trusted
- tests reflect real deployment
- filenames like `secure` or `auth` prove protection
- comments describe enforcement
- a default-safe config covers all supported configs

## Signal Loss

Security reviews are especially sensitive to hidden shortcuts. Report if the analysis skipped:

- runtime config variants
- auth middleware order
- data-flow tracing
- dependency execution paths
- tenant isolation checks
- failure paths

Name the skipped signal and what validation would close it.
