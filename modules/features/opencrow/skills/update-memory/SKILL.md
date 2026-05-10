---
name: update-memory
description: Review recent conversation context and preserve durable memories in ~/notes/memory. Use when the user asks to remember something, save/update memory, commit context to memory, run memory maintenance, or when an automation prompt explicitly asks to run the update-memory skill.
---

# Update Memory

Preserve only useful, durable information from the recent conversation into the shared memory notes for Wiggles and Barnaby.

## Scope

- These memory notes are shared by Wiggles, Phil's private DM opencrow assistant, and Barnaby, the family group-chat opencrow assistant. Anything saved here may be loaded by either bot.
- Review the visible conversation/context only as far back as the previous local calendar day. Ignore anything older.
- Use the local timezone configured for the agent, normally `America/Los_Angeles`.
- If message timestamps are unavailable, use only the recent visible context that clearly belongs to this interaction; do not guess about older context.
- Do not scan unrelated notes, old transcripts, or all of `~/notes` looking for things to remember. Only read/write the memory files described below.

## Files

- Daily memory files live at `~/notes/memory/daily/<YYYY-MM-DD>.md`, where the date is ISO 8601 local date (`date +%F`).
- Long-term memory lives at `~/notes/memory/MEMORY.md`.
- Always ensure `~/notes/memory/daily` and `MEMORY.md` exist.
- Create or update a daily file only when there is a new memory for that local date. If context clearly belongs to both yesterday and today, update each date's file as appropriate; otherwise use today's local date.

Useful setup commands:

```bash
mkdir -p ~/notes/memory/daily
today="$(date +%F)"
yesterday="$(date --date='yesterday' +%F)"
main=~/notes/memory/MEMORY.md
touch "$main"
```

## What to remember

Prefer memory that will help future Wiggles or Barnaby avoid re-learning or repeating mistakes:

- Explicit requests to remember, not forget, save, or treat something as a preference.
- Stable facts about Phil, family, household, projects, recurring workflows, naming conventions, infrastructure, or personal preferences.
- Process notes, gotchas, and lessons learned that would prevent future mistakes.
- Decisions made in conversation that are likely to matter later.
- Pointers to canonical locations for important information when the content itself should not be duplicated.

Do **not** remember:

- Transient tasks, reminders, one-off plans, or calendar-like facts unless the user explicitly wants them remembered.
- Facts that are easy to re-learn from existing notes, repo files, docs, or public sources.
- Raw secrets, passwords, tokens, private keys, or unnecessary sensitive personal details. Store a pointer to where a secret lives only if useful.
- Speculation, uncertain inferences, or emotional color that was not stated.
- Large pasted content; summarize the durable takeaway instead.

## Daily file format

When creating a daily file, use:

```markdown
# Memory — YYYY-MM-DD

- <concise durable memory>
```

Guidelines:

- One memory per bullet.
- Keep bullets short but specific enough to be actionable later.
- Mention the relevant bot or context when it matters, e.g. prefix with `Wiggles:` or `Barnaby:`. Do not prefix generic shared facts.
- If an existing bullet is nearly the same, update it instead of adding a duplicate.
- Use neutral, factual wording. Include names, paths, dates, and project names when they matter.

## MEMORY.md rules

`MEMORY.md` is only for important facts that cannot be easily re-learned if forgotten, especially process notes that prevent future mistakes.

- Read `MEMORY.md` before changing it.
- Add to `MEMORY.md` only when a memory is high-value and long-lived; most memories belong only in the daily file.
- Keep `MEMORY.md` under **10,000 bytes** at all times.
- Cleaning up old, obsolete, duplicate, over-specific, or low-value entries before reaching the byte limit is encouraged.
- If adding new information would make `MEMORY.md` exceed 10,000 bytes, replace or compress less relevant existing content rather than exceeding the limit.
- Never create spillover files for `MEMORY.md`; curate it.

Check size with:

```bash
wc -c < ~/notes/memory/MEMORY.md
```

If creating `MEMORY.md`, start with:

```markdown
# Main Memory

Long-term facts and process notes that are important, durable, and hard to re-learn.

## Durable facts

## Process notes
```

## Procedure

1. Determine local `today` and `yesterday` with `date +%F` and `date --date='yesterday' +%F`.
2. Review only in-scope conversation/context: today and, at most, the previous local calendar day.
3. Extract candidate memories using the criteria above.
4. Create `~/notes/memory/daily` and `MEMORY.md` if needed.
5. Read `MEMORY.md` and any daily memory file(s) you are about to update.
6. Deduplicate and merge with existing bullets.
7. Write daily memories to the appropriate `YYYY-MM-DD.md` file(s).
8. Promote only the most important long-term facts/process notes to `MEMORY.md`.
9. Verify `MEMORY.md` is under 10,000 bytes after editing; curate if necessary.
10. If no new memories are found, leave daily files untouched.

## Heartbeat Response

- If this skill is part of a heartbeat, it is not worth noting what happened.

## Chat Response

- If you changed memory files, reply with a brief summary of the files updated and the memories added or changed.
- If nothing new should be remembered and the invocation appears automated, reply exactly `NO_REPLY`.
- If nothing new should be remembered and the user asked directly, say that there was nothing new worth saving.
