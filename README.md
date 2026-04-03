# Execution Session System

Engineers lose context between work sessions.

You stop working.  
You come back later.  
You don’t remember:
- what you were doing
- why you made certain decisions
- what the next step was

This system prevents that.

---

## What this is

A structured workflow for managing engineering sessions.

It introduces a simple lifecycle:

- **start a session** → rebuild context  
- **check status** → understand current state  
- **record progress** → create checkpoints  
- **end session** → create a clean handoff  
- **recover session** → fix broken context  

---

## Why this matters

Most engineering workflows assume continuous context.

Reality is different.

Work is fragmented:
- meetings  
- interruptions  
- multiple projects  
- long-running tasks  

Without structure, context is lost.

That leads to:
- wasted time  
- repeated analysis  
- inconsistent decisions  
- fragile execution  

This system treats context as something that must be actively preserved.

### Cost and performance impact

In agent-based systems, lost context has a direct cost.

When context is missing, agents:

- re-read files
- re-analyze the same problem
- repeat reasoning steps

This leads to:

- higher token usage
- longer execution time
- increased cost per task

By preserving session state, this system reduces redundant work.

Better context means:

- fewer tokens
- faster execution
- more predictable cost

---

## The model

The system is built around explicit session commands:

```text
/start-session    → rebuild context
/status-session   → inspect current state
/record-session   → checkpoint progress
/end-session      → finalize and hand off
/recover-session  → rebuild from repo

Each command has a clear responsibility.

Together, they form a minimal execution system.

⸻

How it works

The system uses:
	•	lightweight project files (.claude/*)
	•	structured prompts (skills)
	•	simple hooks for session lifecycle

Context is stored in:
	•	session-summary.md → what happened
	•	next-steps.md → what comes next
	•	project-context.md → system understanding

The agent does not rely on memory.

It reconstructs state from these files every time.

## Practical implementation (Claude Code)

This system can be implemented using Claude Code primitives.

### 1. Skills (session commands)

Each session action is implemented as a skill:

- `/start-session`
- `/status-session`
- `/record-session`
- `/end-session`
- `/recover-session`

These define the execution model.

### 2. Hooks (lifecycle automation)

Session lifecycle can be partially automated using hooks:

- session start → initialization
- session end → logging and checkpointing

Configured via:

- `~/.claude/settings.json`
- `~/.claude/hooks/`

These hooks ensure that session boundaries are not implicit — they are enforced.

### 3. Git as execution history

Git is used as part of the execution system — not just version control.

Each meaningful checkpoint can be captured as a commit:

- `/record-session` → optional checkpoint commit
- `/end-session` → clean handoff commit

This creates:

- a timeline of decisions
- traceable execution steps
- recoverable system state

Instead of relying on memory, the system produces an external, verifiable history.

### 4. Project state

Context is stored explicitly in project files:

```text
.claude/
  project-context.md
  session-summary.md
  next-steps.md
```

⸻

Example

Without a system:

Come back after 2 days
→ try to remember
→ re-read code
→ reconstruct context
→ lose 20–30 minutes

With this system:

/status-session
→ immediate understanding
→ continue execution


⸻

What this is not
	•	Not a task manager
	•	Not a note-taking system
	•	Not a memory layer

It is a session execution system.

⸻

Status

Early-stage system.

Actively evolving.

## Installation

This system is tool-agnostic.

You can implement it manually, or use the provided helper script.

### Option 1 — Use helper script

```bash
bash scripts/install-session-system.sh
```

⸻

License

MIT