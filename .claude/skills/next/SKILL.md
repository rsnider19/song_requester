---
name: next
description: Show what to work on next, summarize it, and ask before starting. Reads from BACKLOG.md.
user-invocable: true
disable-model-invocation: false
---

# /next — Work on the next backlog item

You manage the development backlog for this project. The source of truth is `BACKLOG.md` in the project root.

## When invoked, follow these steps exactly

### Step 1: Read the backlog and set session context

Read `BACKLOG.md` and determine the current state. **IMPORTANT:** Your very first text output in this conversation MUST be a clear, descriptive title line for the work item you'll be working on. This is critical because the session title and git branch name are auto-generated from early output. Lead with the item title before any other text.

Format your first output line as:

```
**[Item N]: [Item title]**
```

For example: `**Item 3: Integrate tower display into match screen**`

Then determine:

- **Is there an item marked `in-progress`?** → Go to Step 2a
- **Is there no in-progress item?** → Go to Step 2b

### Step 2a: Resume in-progress work

An item is already in progress. Present it to the user (remember: the item title must be the FIRST thing output):

```
**[Item N]: [Item title]**

Currently in progress. [1-2 sentence summary]
```

Then ask the user (using AskUserQuestion):

- "Continue working on this?" with options:
  - **Continue** — Resume working on this item
  - **Mark done** — Mark it complete and show the next item
  - **Skip** — Move it back to upcoming and promote the next item

If **Continue**: Go to Step 3 (Working on an item), following the approach chosen below.

If **Mark done**: Move the item to the "Done" section of BACKLOG.md (most recent first), and promote the first "Upcoming" item to "Next". Then go to Step 2b to present the new Next item.

If **Skip**: Move the in-progress item back to Upcoming (insert it after the current Next item), and promote the first "Upcoming" to "Next". Then go to Step 2b to present the new Next item.

### Step 2b: Start the next item

No item is in progress. Find the item under the "Next" section. Present it (remember: the item title must be the FIRST thing output):

```
**[Item N]: [Item title]** (Milestone [M])

[The item's Summary field from BACKLOG.md]

**Key files:** [list from backlog]
**Exit criteria:** [list from backlog]
```

Then ask the user (using AskUserQuestion):

- "Start working on this?" with options:
  - **Start** — Begin working on this item
  - **Skip** — Move to the next upcoming item instead
  - **Review backlog** — Show the full list of upcoming items so the user can reprioritize

If **Start**: Move the item from "Next" to "In Progress" in BACKLOG.md. Promote the first "Upcoming" item to "Next". Then go to Step 2c.

If **Skip**: Move the Next item to the end of Upcoming. Promote the first Upcoming item to Next. Present the new Next item and ask again.

If **Review backlog**: List all upcoming items (number, title, milestone) so the user can see the full queue. Ask which one they'd like to promote to Next.

### Step 2c: Choose workflow approach

Before starting work, ask the user how they'd like to approach the item (using AskUserQuestion):

- **Work directly** (Recommended) — Start implementing right away following CLAUDE.md conventions.
- **Full feature workflow** — Run `/feature-workflow` for this item (interview → implement → PR → review → fix → merge).

If **Work directly**: Go to Step 3.

If **Full feature workflow**: Invoke the `feature-workflow` skill with the item's title and summary as the argument. The feature-workflow skill will manage the rest of the lifecycle (interview, implementation, PR, review, fix, merge). When the feature-workflow completes, return here and go to Step 4 (Completing an item).

### Step 3: Working on an item

When you start working on an item:

1. Update BACKLOG.md to show the item as `in-progress`
2. Use TodoWrite to break the item into sub-tasks based on its description and exit criteria
3. Work through the sub-tasks following CLAUDE.md conventions
4. Write tests as specified in exit criteria
5. Run the project's test suite (per CLAUDE.md) before considering the item done
6. When all exit criteria are met, ask the user if they'd like to mark it done

### Step 4: Completing an item

When an item is done:

1. Move it from "In Progress" to the top of the "Done" section in BACKLOG.md
2. Promote first "Upcoming" → "Next"
3. Commit all changes with a conventional commit message
4. Show the user what's next: display the new Next item's title and a one-line summary, but do NOT loop back to Step 2b or ask to start it. The session is done — the user will run `/next` again when they're ready.

## Backlog maintenance rules

- Never reorder upcoming items without the user's explicit approval
- When completing work, if you discover follow-up tasks, add them to Upcoming at the appropriate position and note it to the user
- Keep item descriptions concise — the backlog should be scannable
- If an item turns out to be much larger than expected, suggest splitting it and ask the user
