# slopflow

An opinionated, evidence-first discipline layer for **Claude Code** and **Codex**: the antidote to AI slop.

Coding agents are fast, fluent, and confident. That confidence is the problem: they infer behavior from filenames, trust stale comments, claim things are "already implemented," collapse inference into fact, and optimize for sounding decisive over being right. slopflow installs a shared set of always-on rules plus a skill library that force the opposite habits: ground claims in executable evidence, trace the real production path, reason before converging, and preserve uncertainty instead of hiding it.

## What it installs
slopflow ships two layers:

1. **Always-on prompt**: global instructions loaded into every session.
   - Claude → `~/.claude/CLAUDE.md`
   - Codex → `~/.codex/AGENTS.md`
   - These hold the Core Rules (evidence before claims, production-path first, fact vs inference, signal-loss and metric/oracle audits, meta-level reasoning checks), a compact skill-routing map, the security gate, and output discipline. Detailed procedure lives in the skills, not here.

2. **Skills**: focused workflows loaded on demand when their triggers match. Installed to `~/.claude/skills/<skill>/` and `~/.codex/skills/<skill>/`. Detailed procedure lives here so the always-on prompt stays lean.

## Install

```sh
git clone https://github.com/1ikeadragon/slopflow.git
cd slopflow
./install.sh
```

The installer must be run from a complete checkout (it checks for `CLAUDE.md`, `AGENTS.md`, and `skills/`).

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print every action without touching the filesystem. |
| `--claude-only` | Install only the Claude target. |
| `--codex-only` | Install only the Codex target. |
| `-h`, `--help` | Usage. |

Environment overrides:

| Variable | Default | Purpose |
| --- | --- | --- |
| `CLAUDE_HOME` | `~/.claude` | Claude install root. |
| `CODEX_HOME` | `~/.codex` | Codex install root. |
| `SLOPFLOW_BACKUP_ROOT` | `~/.slopflow-backups/<timestamp>` | Where overwritten files are backed up. |

### Safety and backups

The installer never silently destroys your existing config:

- Any prompt file or same-named skill it is about to overwrite is first copied to `~/.slopflow-backups/<timestamp>/`, mirroring its original path.
- Stale in-place skill backups named `*.bak.*` are moved out of the skills root into the backup directory, so they are not loaded as skills.
- The retired `security-review` skill is removed (after being backed up).

Preview everything first with `./install.sh --dry-run`.

### Uninstall / restore

There is no uninstaller. To revert, restore the relevant files from the most recent `~/.slopflow-backups/<timestamp>/` directory (it mirrors the original paths), and delete any slopflow skill directories you no longer want from `~/.claude/skills/` and `~/.codex/skills/`.

## Skills
Bad at naming stuff so corny names deal wiht it :pray:

| Skill | Use it for |
| --- | --- |
| `reasoning-discipline` | The reasoning spine, applied by default to non-trivial / ambiguous / high-stakes work: frame → generate options → verify → diagnose → evaluate → decide → synthesize, plus meta-level self-checks. |
| `evidence-first` | Grounding any non-trivial claim in executable evidence; classifying code as production / test / legacy; preserving uncertainty. |
| `implementation-discipline` | Making the smallest correct change, with a plan + plan-audit before coding and a post-implementation audit after. |
| `architecture-review` | Mapping active wiring, entrypoints, data/control flow, runtime variants, and failure modes before proposing a design. |
| `code-review-discipline` | Hunting regressions, hidden callers, edge cases, error gaps, and weak tests. Correctness over politeness. |
| `adversarial-test-design` | Invariant-driven tests that attack assumptions, for security-sensitive, correctness-critical, parser, workflow, and AI/LLM logic. |
| `legacy-cleanup` | Classifying code by reachability before deletion; quarantine/delete decisions with validation. |
| `rca-investigation` | Cumulative, proof-driven root-cause analysis with competing hypotheses and code/config/DB/git tracing. |
| `workflow-rca` | Collecting workflow/runtime evidence (Temporal/CI IDs, cloud logs, artifacts, cache state) to feed `rca-investigation`. |
| `rigorous-web-research` | Current external research with hard citations: competitor practice, primary docs, recent papers, benchmarks. |
| `secure-design` | Threat-model-by-sub-component review for security-relevant changes, triggered via the always-on Security Gate. |

The installer auto-discovers every directory under `skills/` that contains a `SKILL.md`, so adding a skill is just adding a folder.

## Philosophy
- **Evidence before claims.** Filenames, comments, and READMEs are hints, not proof.
- **Production path first.** Trace from a real entrypoint before judging or changing behavior.
- **Separate fact from inference.** Observed / Inferred / Uncertain / Conclusion.
- **No hidden signal loss.** Call out every shortcut, mock, fallback, or truncation and its risk.
- **Reason before converging.** Frame the problem, generate real alternatives, decide deliberately.
- **Preserve uncertainty.** A correct uncertain answer beats a confident false one.

## Credits
The reasoning discipline skill draws inspiration from s0md3v's overthink skill

## License

[MIT](./LICENSE)
