#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
import os
from pathlib import Path

home = Path.home()
claude_dir = home / ".claude"
hooks_dir = claude_dir / "hooks"
skills_dir = claude_dir / "skills"

overwrite = False

print("==> Installing execution session system (global)")

# ---------------------------
# helpers
# ---------------------------

def write(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n", encoding="utf-8")

def write_if_missing(path: Path, content: str):
    if path.exists() and not overwrite:
        print(f"==> Skipping {path}")
        return
    write(path, content)
    print(f"==> Wrote {path}")

# ---------------------------
# directories
# ---------------------------

hooks_dir.mkdir(parents=True, exist_ok=True)

for s in [
    "start-session",
    "status-session",
    "record-session",
    "end-session",
    "recover-session",
    "init-project",
]:
    (skills_dir / s).mkdir(parents=True, exist_ok=True)

# ---------------------------
# settings.json
# ---------------------------

write_if_missing(
    claude_dir / "settings.json",
    json.dumps({
        "hooks": {
            "SessionStart": [{
                "matcher": "startup|resume|clear|compact",
                "hooks": [{
                    "type": "command",
                    "command": "~/.claude/hooks/session-start.sh"
                }]
            }],
            "SessionEnd": [{
                "matcher": ".*",
                "hooks": [{
                    "type": "command",
                    "command": "~/.claude/hooks/session-end.sh"
                }]
            }]
        }
    }, indent=2)
)

# ---------------------------
# hooks
# ---------------------------

write_if_missing(
    hooks_dir / "session-start.sh",
    """#!/usr/bin/env bash
echo "[session-start]"
"""
)

write_if_missing(
    hooks_dir / "session-end.sh",
    """#!/usr/bin/env bash
echo "[session-end]"
"""
)

os.chmod(hooks_dir / "session-start.sh", 0o755)
os.chmod(hooks_dir / "session-end.sh", 0o755)

# ---------------------------
# skills
# ---------------------------

write_if_missing(
    skills_dir / "start-session" / "SKILL.md",
    """---
name: start-session
description: Rebuild working context at session start
---

- check git state
- read CLAUDE.md + .claude/*
- identify current focus
- output one next step
"""
)

write_if_missing(
    skills_dir / "status-session" / "SKILL.md",
    """---
name: status-session
description: Show current state (read-only)
---

- read CLAUDE.md + .claude/*
- show current focus
- show repo state
- show next step
"""
)

write_if_missing(
    skills_dir / "record-session" / "SKILL.md",
    """---
name: record-session
description: Save checkpoint during session
---

- update session-summary
- update next-steps
- propose commit
"""
)

write_if_missing(
    skills_dir / "end-session" / "SKILL.md",
    """---
name: end-session
description: Finalize session
---

- update session-summary
- rewrite next-steps
- propose commit
"""
)

write_if_missing(
    skills_dir / "recover-session" / "SKILL.md",
    """---
name: recover-session
description: Recover session state
---

- ignore chat
- read repo + .claude
- rebuild state
- output next step
"""
)

write_if_missing(
    skills_dir / "init-project" / "SKILL.md",
    """---
name: init-project
description: Initialize repo for execution session system
---

- inspect repo
- create CLAUDE.md
- create .claude/*
- evaluate .gitignore
- output next step
"""
)

print("==> Done")
print("Available commands:")
print("/init-project /start-session /status-session /record-session /end-session /recover-session")

PY