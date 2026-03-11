---
name: work-status
description: >
  This skill should be used when the user says "work status", "show my work",
  "what work am I on". Show raw work note for the current branch.
---

# work-status

1. Read `_notes/_summary.md` in cwd
2. If not found, also check `_summary.md` in cwd (legacy layout)
3. If still not found — scan immediate subdirectories for `_notes/_summary.md` or `_summary.md`:
   - If exactly one found — use it
   - If multiple found — list them and ask user which to show
   - If none found — suggest `start work`
4. Display raw content
