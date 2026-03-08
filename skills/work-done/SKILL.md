---
name: work-done
description: >
  This skill should be used when the user says "work done", "done with work",
  "finish work", "mark complete", "close work". Mark work complete by updating the work note.
---

# work-done

1. Read `_summary.md` in cwd
2. If not found — tell user, suggest `start work`
3. Update the file:
   - Frontmatter: `status: active` -> `status: done`, add `completed: YYYY-MM-DD`
   - Append to Progress Log: `- YYYY-MM-DD: Work marked done`
4. Confirm: work note updated, status = done
