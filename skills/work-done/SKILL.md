---
name: work-done
description: >
  This skill should be used when the user says "work done", "done with work",
  "finish work", "mark complete", "close work". Mark work complete by updating the work note.
---

# work-done

1. Read `_notes/_summary.md` in cwd
2. If not found — tell user, suggest `start work`
3. Update the file:
   - Frontmatter: `status: active` -> `status: done`, add `completed: YYYY-MM-DD`
   - Append to `_notes/worklog.md`: `- YYYY-MM-DD: Work marked done`
4. Confirm: work note updated, status = done

## MANDATORY: Update Notes

**After completing ANY action in this skill, you MUST update `_notes/worklog.md`** with a timestamped entry describing what was done. Format:
```
- YYYY-MM-DD HH:MM: <action summary>
```

Never skip this step. Notes are the primary deliverable, not a side-effect.
