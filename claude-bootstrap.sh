#!/usr/bin/env bash
set -euo pipefail

python3 - "$@" <<'PY'
import json
import os
import sys
from pathlib import Path

mode = "all"
overwrite_project = False
overwrite_global = False

for arg in sys.argv[1:]:
    if arg == "--global-only":
        mode = "global"
    elif arg == "--project-only":
        mode = "project"
    elif arg == "--overwrite-project-files":
        overwrite_project = True
    elif arg == "--overwrite-global-files":
        overwrite_global = True
    else:
        print(f"Unknown argument: {arg}", file=sys.stderr)
        sys.exit(1)

home = Path.home()
claude_dir = home / ".claude"
hooks_dir = claude_dir / "hooks"
skills_dir = claude_dir / "skills"

project_root = Path.cwd()
project_name = project_root.name
project_claude = project_root / ".claude"

print("==> Bootstrap v2.5 starting...")

# ---------------------------
# helpers
# ---------------------------

def write(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n", encoding="utf-8")

def write_global(path: Path, content: str):
    if path.exists() and not overwrite_global:
        print(f"==> Skipping global {path}")
        return
    write(path, content)
    print(f"==> Wrote global {path}")

def write_project(path: Path, content: str):
    if path.exists() and not overwrite_project:
        print(f"==> Skipping project {path}")
        return
    write(path, content)
    print(f"==> Wrote project {path}")

# ---------------------------
# GLOBAL SETUP
# ---------------------------

def setup_global():
    print("==> Installing global config")

    hooks_dir.mkdir(parents=True, exist_ok=True)

    for s in ["start-session","status-session","record-session","end-session","recover-session"]:
        (skills_dir / s).mkdir(parents=True, exist_ok=True)

    write_global(claude_dir / "settings.json", json.dumps({
        "hooks": {
            "SessionStart": [{
                "matcher": "startup|resume|clear|compact",
                "hooks": [{"type": "command","command": "~/.claude/hooks/session-start.sh"}]
            }],
            "SessionEnd": [{
                "matcher": ".*",
                "hooks": [{"type": "command","command": "~/.claude/hooks/session-end.sh"}]
            }]
        }
    }, indent=2))

    write_global(hooks_dir / "session-start.sh", "#!/usr/bin/env bash\necho session start\n")
    write_global(hooks_dir / "session-end.sh", "#!/usr/bin/env bash\necho session end\n")

    # ---------- skills ----------

    write_global(skills_dir / "start-session" / "SKILL.md", """---
name: start-session
description: Rebuild working context at session start
---

Do NOT modify files.

- check git (branch + clean/dirty)
- read CLAUDE.md + .claude/*
- identify current focus
- output 1 exact next step
""")

    write_global(skills_dir / "status-session" / "SKILL.md", """---
name: status-session
description: Show current state (read-only)
---

Do NOT modify files.

Return:
- current focus
- next step
- repo state (branch + clean/dirty)
- changed files
- last commit
""")

    write_global(skills_dir / "record-session" / "SKILL.md", """---
name: record-session
description: Save checkpoint during session
---

- update session-summary
- update next-steps
- propose commit
- ask before commit
""")

    write_global(skills_dir / "end-session" / "SKILL.md", """---
name: end-session
description: Finalize session and create handoff
---

- update session-summary
- rewrite next-steps
- propose commit
- ask before commit
""")

    write_global(skills_dir / "recover-session" / "SKILL.md", """---
name: recover-session
description: Recover broken session
---

- ignore chat
- read repo + .claude
- detect drift
- rebuild state
- output next step
""")

# ---------------------------
# PROJECT SETUP
# ---------------------------

def setup_project():
    print("==> Installing project files")

    project_claude.mkdir(exist_ok=True)

    write_project(project_root / "CLAUDE.md", """
# Project instructions

Use:
/start-session
/status-session
/record-session
/end-session
/recover-session
""")

    write_project(project_claude / "project-context.md", """
# Project Context

Describe the project
""")

    write_project(project_claude / "session-summary.md", """
## What we did
- bootstrap
""")

    write_project(project_claude / "next-steps.md", """
# Next Steps

1. analyze repo
""")

# ---------------------------
# EXECUTION
# ---------------------------

if mode in ("all","global"):
    setup_global()

if mode in ("all","project"):
    setup_project()

print("==> Done")
PY