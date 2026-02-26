---
name: feature-workflow
description: End-to-end feature workflow — interview, implement, review, fix, retro. Orchestrates the full lifecycle of building a feature with local code review. Also usable as a standalone interview via "/feature-workflow interview".
user-invocable: true
disable-model-invocation: false
argument-hint: "[feature description] or 'interview [topic]'"
---

# Feature Workflow

You are now in **feature workflow mode**. This orchestrates the full lifecycle of building a feature through sequential phases:

1. **Interview** — Thoroughly analyze the feature with the user
2. **Implement** — Write code and tests
3. **Review** — Spawn a review agent to critique the changes locally
4. **Fix** — Spawn a fix agent to address review comments
5. **Complete** — Get user approval, finalize the feature
6. **Retro** — Aggregate learnings from the workflow and update CLAUDE.md

**Follow each phase in order. Do NOT skip phases. Do NOT proceed to the next phase until the current one is complete.**

### Interview-Only Mode

If the user's argument starts with "interview" (e.g., `/feature-workflow interview <topic>`), run **only Phase 1** (the interview). After the user approves the summary, ask whether they want to continue to Phase 2 (implementation) or stop here. If they stop, exit the workflow — the approved summary serves as a standalone spec.

---

## Phase 1: Interview & Analysis

Your job is to deeply understand what the user wants before writing any code.

### Rules

- **No code yet.** Do not write, edit, suggest, or generate any code during this phase. You may read existing code to understand context, but all output should be questions and discussion.
- **Use AskUserQuestion relentlessly.** Every response must include at least one AskUserQuestion call. Keep asking until every ambiguity is resolved.
- **ONE question at a time.** Each AskUserQuestion call must contain exactly ONE question. Do not ask multiple questions in a single response. Wait for the user's answer before asking the next question. This keeps the conversation focused and avoids overwhelming the user.
- **State your recommendation.** When presenting options, clearly indicate which you recommend and why. Put your recommended option first in the list and mark it with "(Recommended)". If you don't have enough context to recommend, say so and explain what would help you form one.
- **Listen and reflect.** Before moving to the next topic, briefly summarize what you understood from the user's answer so they can correct any misunderstanding.
- **Go deep, not wide.** Follow up on vague answers rather than assuming.
- **Challenge assumptions.** If the user's idea has potential issues (performance, UX, complexity, edge cases), raise them as questions — not objections.
- **It is always better to ask one more question than to assume.** Thorough planning saves rework. If the user tries to rush to code, gently remind them of this.

### Interview Flow

#### Problem & Context

- What problem does this feature solve?
- Who is the user/audience?
- Current behavior vs. desired behavior?
- Prior art, reference implementation, or design/screenshot?

#### Requirements & Scope

- Must-have behaviors? Explicitly out of scope?
- Inputs, outputs, key interactions?
- Edge cases and error states?
- Interactions with existing features?

#### Technical Considerations

- Read relevant existing code to understand architecture.
- Constraints: performance, platform differences, backward compatibility.
- Affected layers: UI, state, service, repository, database, server.
- Feature flags, analytics events, permissions?

#### UX & Design

- Walk through user flow step by step.
- Loading, error, empty states.
- Animations, transitions, feedback.
- Accessibility considerations.

#### Testing & Acceptance

- What does "done" look like?
- Specific test scenarios?
- Performance benchmarks?

Adapt the phases above to what makes sense — skip phases that don't apply, but never skip asking questions.

### Wrapping Up the Interview

When you believe the feature is fully understood:

1. **Present a complete summary** covering: problem statement, requirements (must-have and out-of-scope), technical approach, UX flow, edge cases, testing criteria, and any open questions.
2. **Ask the user to approve** using AskUserQuestion:
   - If running the **full workflow**: options are "Approved — start implementation" and "Needs changes".
   - If running **interview-only mode**: options are "Approved — start implementation", "Approved — stop here (save as spec)", and "Needs changes".
3. **Only after explicit approval**, proceed to Phase 2 (or exit if interview-only and the user chose to stop).

---

## Phase 2: Implementation

Implement the feature based on the approved interview summary.

1. **Create a feature branch** if not already on one: `git checkout -b feat/<feature-name>` from the latest `main`.
2. **Use TodoWrite** to create a detailed task list from the interview summary. Break it into small, logical units.
3. **Follow all patterns and conventions from CLAUDE.md.**
4. **Write tests alongside implementation** — this is mandatory per CLAUDE.md. Every module, service, and component must have corresponding tests.
5. **Run code generation** if any generated files were affected (see CLAUDE.md for the appropriate command).
6. **Run tests** and fix failures (see CLAUDE.md for the appropriate command).
7. **Run linting/analysis** and fix issues (see CLAUDE.md for the appropriate command).
8. **Commit changes** using conventional commits. Break into small, logical commits — each should represent a single cohesive unit of work.

When implementation is complete and all tests pass, proceed to Phase 3.

---

## Phase 3: Local Code Review (Separate Agent)

Spawn a **Task agent** (`subagent_type: "general-purpose"`) to perform a thorough local code review of all changes on the feature branch.

**Before spawning the agent**, determine the base branch (usually `main`) and capture the diff range:

```bash
git diff main...HEAD --stat
```

**The review agent's prompt must include:**

1. The base branch and instructions to get the diff using `git diff main...HEAD`.
2. Instructions to read the project's CLAUDE.md file for conventions.
3. The full review checklist below.
4. Instructions to write findings to a local review file.

**Review agent prompt template:**

```
You are a senior engineer reviewing the changes on the current feature branch.

## Setup
1. Run `git diff main...HEAD` to get the full diff of all changes on this branch.
2. Run `git log main...HEAD --oneline` to see all commits on this branch.
3. Read CLAUDE.md for project conventions.
4. Read any files that are touched by the diff to understand full context (not just the diff).

## Review Checklist
Evaluate every changed file against these criteria:

### Architecture
- Does the code follow the project's layered architecture (per CLAUDE.md)?
- Are layers properly separated with clear responsibilities?
- Are conventions for data access, services, and UI layers followed?

### Code Quality
- Clean, readable code with clear naming?
- No dead code, unused imports, or commented-out code?
- No over-engineering — only changes directly needed for the feature?

### Tests
- Are tests present for every new module, service, and component?
- Do tests cover happy paths, error paths, and edge cases?
- Are tests testing behavior/outcomes, not implementation details?

### Edge Cases & Error Handling
- Missing error handling at system boundaries?
- Null/undefined safety issues?
- Race conditions in async code?
- Proper error types with descriptive messages?

### CLAUDE.md Compliance
- Does the code follow all conventions defined in CLAUDE.md?
- Conventional commit messages?

### Security
- No injection vulnerabilities?
- Input validation at system boundaries?
- No secrets or credentials in code?

### Potential Bugs
- Logic errors, off-by-one issues?
- Incorrect state transitions?
- Missing null/undefined checks?

## Output
Structure your review as a report and return it directly (do NOT write it to a file). Use this format:

### Review Summary
<1-2 sentence overall assessment>

### Issues Found
For each issue:
- **[SEVERITY]** (Critical / Major / Minor / Nit)
- **File**: `path/to/file.dart:line`
- **Issue**: What's wrong
- **Suggestion**: How to fix it

### What Looks Good
<Brief positive notes on well-done aspects>

Be constructive and specific. Every issue must include a concrete suggestion for how to fix it.
```

**After the review agent completes**, read its output and summarize the findings for the user before proceeding to Phase 4.

---

## Phase 4: Fix Review Comments (Separate Agent)

Spawn a **Task agent** (`subagent_type: "general-purpose"`) to address the review comments locally.

**The fix agent's prompt must include:**

1. The review findings (pass the full review output from Phase 3).
2. Instructions to read CLAUDE.md for project conventions.
3. Instructions to fix each issue, commit locally.

**Fix agent prompt template:**

```
You are a developer addressing code review feedback on the current feature branch.

## Setup
1. Read CLAUDE.md for project conventions.

## Review Findings to Address
<PASTE THE FULL REVIEW OUTPUT FROM PHASE 3 HERE>

## Instructions
For each review issue (prioritize Critical > Major > Minor > Nit):

1. **Read the relevant file** to understand full context.
2. **Make the fix** following CLAUDE.md conventions.
3. **Update or add tests** if the fix requires it.
4. **Commit** with a conventional commit message referencing the review point:
   - e.g., `fix: validate input before processing per review feedback`
   - e.g., `refactor: rename provider to follow naming convention`

After all fixes:
5. **Run code generation** if any generated files were affected (see CLAUDE.md for the appropriate command).
6. **Run tests** (see CLAUDE.md for the appropriate command).
7. **Run linting/analysis** (see CLAUDE.md for the appropriate command).

Return a summary of what was fixed, organized by severity. If you disagree with a review point, explain why rather than silently ignoring it.

```

**After the fix agent completes**, read its output and proceed to Phase 5.

---

## Phase 5: Completion

1. **Check the final state** of the branch:
   ```bash
   git diff main...HEAD --stat
   git log main...HEAD --oneline
   ```

1. **Present a summary to the user** including:
   - What the review found (number and severity of issues)
   - What the fix agent addressed
   - Current test and analysis status
   - Final diff stats (files changed, insertions, deletions)

2. **Ask the user for approval** using AskUserQuestion:

   ```
   options:
   - "Done — push and wrap up" (Recommended)
   - "More changes needed" — describe what else needs work
   - "Abandon — discard changes"
   ```

3. **If approved**:
   - Ensure all changes are committed with conventional commit messages
   - Push the branch:

     ```bash
     git push -u origin <branch-name>
     ```

   - Tell the user the branch has been pushed and is ready for PR creation (or whatever their workflow requires).

4. **If more changes needed**, ask what needs to change and loop back to the appropriate phase (implementation or fix).

5. **If abandoned**, confirm with the user before discarding any work.

---

## Phase 6: Retrospective & CLAUDE.md Update

After the feature is complete (or after Phase 5 if the user chose to abandon), run a retrospective to capture learnings from the entire workflow.

### Purpose

Sub-agents (review, fix) operate without shared memory. They often discover patterns, pitfalls, or conventions that should be codified. The orchestrating agent has visibility across all phases and can aggregate these insights into durable guidance in CLAUDE.md.

### Process

1. **Reflect on the full workflow.** Review what happened across all phases:
   - What did the **review agent** flag? Were the issues systemic (likely to recur) or one-off?
   - What did the **fix agent** struggle with or get wrong? (e.g., ran build_runner incorrectly, deleted files, missed a convention)
   - What **patterns or conventions** were unclear, leading to mistakes or review feedback?
   - What **tooling issues** came up? (e.g., missing SDKs, CLI tools, environment quirks)
   - Were there any **architectural decisions** made during this feature that future features should follow?

2. **Identify CLAUDE.md update candidates.** Only propose updates that are:
   - **Generalizable** — applies to future work, not just this feature
   - **Non-obvious** — not already covered or easily inferred from existing docs
   - **Actionable** — a concrete rule, pattern, or example that prevents a specific mistake
   - **Battle-tested** — the learning came from an actual mistake or discovery, not speculation

3. **Draft proposed updates.** For each candidate, write the exact text to add to CLAUDE.md. Categorize as:
   - **New section** — a pattern or convention not yet documented
   - **Amendment** — a clarification or addition to an existing section
   - **Example** — a new code example for an existing convention

4. **Present to the user** using AskUserQuestion. Show each proposed update and ask:

   ```
   options:
   - "Apply all updates"
   - "Let me pick which ones" — then show each individually
   - "Skip retro — no updates needed"
   ```

5. **Apply approved updates** to CLAUDE.md. Commit with:

   ```
   docs(claude): update CLAUDE.md with learnings from <feature-name>
   ```

### What NOT to Update

- Don't add guidance that's only relevant to this specific feature
- Don't add guidance that duplicates existing CLAUDE.md content
- Don't add speculative "best practices" — only things proven by this workflow
- Don't bloat CLAUDE.md with excessive detail — keep entries concise and scannable
- If there are no genuine learnings, skip the update entirely and tell the user

### Examples of Good Retro Learnings

- Review found that domain models stored the same data in two places → Add a "Single source of truth for domain data" rule
- Fix agent ran `build_runner` wrong and deleted all generated files → Add a warning about `build_runner clean` behavior
- Interview revealed a pattern for how Freezed models should handle nullable nested objects → Add example to Freezed section
- Sub-agents consistently forgot a naming convention → Make the convention more prominent with a CORRECT/INCORRECT example

---

## Important Notes

- **Never skip the interview phase.** Thorough planning prevents rework.
- **Each phase must fully complete** before the next begins.
- **The review and fix agents are separate Task agents** — they do not share memory with the main conversation. Provide them with all necessary context in their prompts.
- **Keep the user informed** between phases with brief status updates.
- **If any phase fails** (tests fail, git commands error, etc.), fix the issue before proceeding.
- **The retro phase is lightweight.** If the workflow went smoothly with no learnings, skip it with a brief note. Don't force updates.
