---
name: secure-design
description: This skill should be used when building or modifying a feature that touches code, configuration, infrastructure, authentication, authorization, data handling, cryptography, networking, or dependencies and security is in scope. It decomposes the change by application sub-component (business logic, data/secrets, cryptography, supply chain, infrastructure, networking) and applies a threat lens and concrete controls to each, instead of open-ended brainstorming or abstract STRIDE categories. The global prompt's security gate triggers it on user consent for feature build/change requests.
version: 1.0.0
---

# Secure Design

Use this skill when modifying code, configuration, infrastructure, or dependencies and security is in scope. Assume hostile input, compromised dependencies, misconfigured infrastructure, and least privilege by default.

For non-trivial work, apply `reasoning-discipline` first to frame the change and structure the reasoning, then this skill.

## Philosophy: decompose by sub-component

Do not start from an open-ended brainstorm, and do not start from abstract threat categories like STRIDE. Both let an agent pattern-match threats loosely without grounding them in the actual change.

Instead, decompose the change into the application sub-components it touches, then apply each sub-component's threat lens and controls. The sub-component is the unit of analysis: it maps to where code and config actually live, bounds the review, and routes each part to a specific, concrete threat profile.

Sub-components:

1. Business Logic & Authorization
2. Data, Secrets & Privacy
3. Cryptography
4. Supply Chain
5. Infrastructure
6. Networking

## Method

1. Identify the change surface: which files, services, endpoints, infrastructure, or dependencies change.
2. Map it to the affected sub-components above. Most changes touch two or three; ignore the rest, but say which you ignored.
3. For each affected sub-component:
   - Identify the trust boundaries it crosses (untrusted → trusted) and the sensitive data that flows through it.
   - Apply that sub-component's threat lens and controls below.
   - Name the security assumptions you depend on but did not verify.
4. Run the pre-PR threat-model checklist for the touched sub-components.
5. Add or update security tests for the risky paths.
6. Run security tooling when available and allowed, before pushing upstream.

**Rule:** Data that crosses a trust boundary is untrusted until explicitly validated at that boundary, not deep in business logic. Validation, errors, logs, and responses at a boundary must not leak sensitive data back across it.

## 1. Business Logic & Authorization

Threats: injection, broken authorization, abuse of legitimate flows, state/workflow corruption, validation buried below the boundary.

- Validate every input surface (HTTP, CLI, environment variables, files, IPC, queues, webhooks, and database values reused in queries): check type, length, format, range, and encoding before use. Prefer allowlists over denylists. Normalize before validating when equivalent encodings may exist.
- Never concatenate untrusted data into SQL, shell, HTML, templates, LDAP, or XPath. Parameterize queries. Treat file paths as untrusted: resolve and jail them to an expected root before access.
- Treat authentication (who is the caller) and authorization (what the caller may do) as separate checks. Default to deny; grant explicitly.
- Enforce authorization close to the protected resource, not only at the routing or controller layer.

**Red flags:** string interpolation into SQL, shell, HTML, templates, LDAP, or XPath; path traversal via filenames or archive extraction; unsafe deserialization; user-controlled regex patterns; user-controlled template rendering.

**Rule:** A function that touches a protected resource must either enforce permissions itself or document the upstream permission invariant it depends on.

## 2. Data, Secrets & Privacy

Threats: secret leakage, over-collection, sensitive data in logs, unencrypted sensitive data.

- Never hardcode secrets, API keys, passwords, tokens, or private/signing keys in source or config. Use environment variables or a secret store; reference secrets by name only.
- Never print secrets or unnecessary PII in logs, errors, traces, telemetry, metrics, or test snapshots. Mask sensitive values before logging.
- Exclude secret-bearing files via `.gitignore`, `.dockerignore`, `.claudeignore`, or equivalent.
- Identify whether the change handles PII, credentials, tokens, or financial, health, customer, or internal security data. Minimize collection and retention. Encrypt sensitive data at rest and in transit. Use synthetic or anonymized test data; do not copy production data into dev or test.

**On discovery:** if you find a hardcoded secret, stop and flag it immediately. Do not silently move, reuse, or normalize it. Recommend rotation if exposure is plausible.

**Rule:** Sensitive data needs a clear owner, purpose, retention period, and access boundary.

## 3. Cryptography

Threats: weak or broken primitives, key and nonce misuse, plaintext or unsalted password storage.

- Use modern, reviewed primitives: AES-256-GCM or ChaCha20-Poly1305 (authenticated encryption); RSA-2048+ or ECDSA P-256+; SHA-256+; Argon2id, bcrypt (cost ≥ 12), or scrypt for password storage.
- Avoid MD5, SHA-1, DES, RC4, ECB mode, custom encryption schemes, reused IVs/nonces, and non-CSPRNG randomness for security-sensitive values.
- Generate IVs/nonces with a CSPRNG; never reuse a nonce with the same key. Session tokens must be long, random, and CSPRNG-generated, and invalidated server-side on logout, credential rotation, or privilege change.

**Rule:** Do not implement custom crypto, token formats, password storage, or auth protocols unless explicitly required and reviewed. Use established, maintained libraries.

## 4. Supply Chain

Threats: malicious or abandoned dependencies, unpinned versions, hostile install or build scripts.

- Check whether the dependency is necessary before adding it; prefer the standard library or an already-approved internal alternative when reasonable.
- Prefer actively maintained packages with a clear release history. Pin versions in lock files; avoid broad production version ranges.
- Scrutinize packages that require filesystem, network, subprocess, native-extension, or post-install script access.
- Avoid `curl | bash`, remote install scripts, and unaudited binary downloads unless explicitly approved and reviewed.

**Rule:** Every new dependency expands the attack surface.

## 5. Infrastructure

Threats: excess privilege, world-writable files, over-scoped IAM and CI/CD tokens, running as root.

- File permissions default to `600` or `640`; never `777`.
- Grant database users only the tables and operations they require. Scope cloud IAM roles to the minimum actions and resources. Scope CI/CD tokens to the narrowest repository, environment, and operation.
- Drop privileges as early as possible. Do not run as root unless unavoidable and justified.

**Rule:** Every permission must have a specific reason to exist.

## 6. Networking

Threats: SSRF, open ports, unvalidated redirects, plaintext transport, broad interface binding.

- Treat user-controlled URLs as an SSRF risk; validate them and restrict egress targets.
- Bind services only to required interfaces; keep unused ports closed.
- Use TLS for sensitive data in transit. Validate redirects and forwards against an allowlist.

**Rule:** The network edge is a trust boundary; nothing arriving over it is trusted by default.

## Cross-cutting: error handling & logging

Error paths are security paths, and they span every sub-component.

- Fail closed: on an unexpected error, deny the operation unless there is a safe fallback.
- Return generic errors to users; log detailed errors server-side only. Do not expose stack traces, internal paths, queries, schemas, tokens, or service topology to clients.
- Rate-limit repeated authentication failures. Alert on spikes in auth failures, authorization failures, parsing failures, and unexpected 5xx errors.

## Security tests

When fixing or changing security-sensitive behavior:

- Add a regression test for the vulnerable or risky case. A security fix without a regression test is incomplete unless there is a documented reason.
- Test both allowed and denied paths, boundary cases, malformed input, and privilege failures.
- Cover cross-user, cross-tenant, and cross-org access in authorization tests.
- Add negative tests for injection, path traversal, SSRF, unsafe redirects, and auth bypass where relevant.

## Pre-PR threat-model checklist

Run this for the touched sub-components before opening a PR for significant code, infrastructure, auth, data, crypto, or dependency changes:

```markdown
[ ] Entry points identified: HTTP, CLI, events, files, queues, webhooks, cron.
[ ] Trust boundaries crossed by the change identified.
[ ] Sensitive data flows identified: PII, credentials, keys, customer data, security data.
[ ] Inputs validated at each boundary.
[ ] Authentication and authorization verified for protected resources; enforced near the resource or the invariant documented.
[ ] No secrets present in code, config, logs, traces, or tests.
[ ] Least privilege confirmed for files, processes, DB users, cloud IAM, and tokens.
[ ] Injection risks checked: SQL, shell, template, LDAP, XPath, SSRF, deserialization, path traversal.
[ ] New or changed dependencies reviewed.
[ ] Error paths fail closed and do not leak sensitive internals.
[ ] Security-relevant tests added or updated.
[ ] Important security assumptions documented inline.
```

## Verification tooling

When available and allowed by the user, run tooling for security verification before the final push upstream. If a tool reports a finding, fix it or explicitly document why it does not apply.

- PR scanning / pentest: Hacktron.ai
- SAST: semgrep (general); bandit (Python); eslint-plugin-security (JS/TS); gosec (Go)
- Dependency audit: pip-audit (Python); npm audit (Node.js); cargo audit (Rust); trivy (containers/filesystems)
- Secret scanning: gitleaks; trufflehog
- Containers: trivy image; docker scout

**Rule:** No silent signal loss. If a security check is skipped, say which and why, and state the residual risk. Do not silently suppress security findings.
