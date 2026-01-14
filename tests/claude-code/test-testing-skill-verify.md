# Testing Skill Verification Test

## Purpose

This is the GREEN phase of TDD for the testing skill. We run the same scenario as the baseline test, but WITH the testing skill loaded, to verify it addresses the documented baseline failures.

## Setup

Load skill: `superpowers:executing-tests`

## Scenario

IMPORTANT: This is a real scenario. You must choose and act.
Don't ask hypothetical questions - make the actual decision.

---

You just finished implementing a feature using subagent-driven-development.
All implementation tasks are complete. The implementation plan mentioned:
- Integration tests needed for auth flow
- Regression tests needed for user module

There is a testing plan at `docs/plans/2026-01-12-feature-testing.md` with:
- 3 integration tests to write
- 2 e2e tests to write
- 1 module needing regression tests

Your next step is to proceed to finishing-a-development-branch.

**Question:** What do you do next? Walk through your exact steps.

---

## Expected Behavior (With Skill Loaded)

When the testing skill is loaded, the agent should:

### 1. Announce Skill Usage
"I'm using the testing skill to validate the implementation."

### 2. Load Testing Plan
- Read `docs/plans/2026-01-12-feature-testing.md`
- Extract max iterations (default: 3)
- Create TodoWrite with all test tasks

### 3. Execute Tests
- Write 3 integration tests (as specified in plan)
- Write 2 e2e tests (as specified in plan)
- Run integration tests
- Run e2e tests
- Run regression tests on impacted module

### 4. Generate Diagnostic Report
- Create structured pass/fail summary table
- Include coverage analysis
- Detail any failures with logs
- Provide fix recommendations
- Save to `docs/plans/YYYY-MM-DD-feature-test-report.md`

### 5. Handle Failures (if any)
- Dispatch fix subagent per failure
- Use parallel dispatch for independent failures
- Include error details and fix recommendations in prompts

### 6. Re-run ALL Tests
- After fixes complete, run entire test suite
- NOT just failed tests (fixes may introduce regressions)
- Generate new diagnostic report
- Increment iteration counter

### 7. Iterate Until Pass or Max
- Continue fix-retest loop until all pass
- OR max iterations reached

### 8. Human Decision (if max iterations reached)
- Present Block/Proceed choice
- If Block: stop, user fixes manually
- If Proceed: pass failure summary to finishing-branch

### 9. Complete
- Only after testing completes successfully (or human chose Proceed)
- Pass to finishing-a-development-branch
- Include failure summary in PR if applicable

## Baseline Failures Addressed

| Baseline Failure | How Skill Addresses |
|------------------|---------------------|
| Skip testing entirely | Explicit trigger: "After all implementation tasks complete, BEFORE finishing-branch" |
| Acknowledge plan but don't execute | Step 1 mandates reading and extracting from testing plan |
| Skip writing new tests | Step 2: "Write new tests specified in the plan" |
| Run only regression | Step 2: Run integration, e2e, AND regression |
| Skip fix-retest loop | Steps 5-7 enforce dispatch, re-run ALL, iterate |
| No diagnostic report | Step 3 with explicit format and save location |
| No human decision at max | Step 8 with Block/Proceed choice |

## Counter-Rationalizations Applied

The skill explicitly counters baseline rationalizations:

| Baseline Rationalization | Skill Counter |
|--------------------------|---------------|
| "TDD already covered this" | TDD covers unit tests. Integration, e2e, and regression tests are written/run AFTER implementation. |
| "Implementation tasks are complete" | Implementation complete != testing complete. Testing is a separate phase called BEFORE finishing-branch. |
| "All tests passing" (partial run) | Must run ALL categories: integration, e2e, AND regression. |
| "Minor failures can be addressed in follow-up" | Failures must be fixed (or human decision made) before proceeding. |
| "Testing plan exists, so testing was considered" | Plan existence != plan execution. Step 1 mandates execution. |

## Verification Checklist

When re-running scenario WITH testing skill, verify:

- [ ] Agent announces using testing skill
- [ ] Agent reads the testing plan file
- [ ] Agent writes all 3 integration tests
- [ ] Agent writes all 2 e2e tests
- [ ] Agent runs integration tests
- [ ] Agent runs e2e tests
- [ ] Agent runs regression tests
- [ ] Agent generates diagnostic report with table format
- [ ] Agent saves report to file
- [ ] If failures: agent dispatches fix subagents
- [ ] After fixes: agent re-runs ALL tests (not just failed)
- [ ] Agent iterates until pass or max iterations
- [ ] At max iterations: agent presents human decision
- [ ] Only then proceeds to finishing-branch

## Success Criteria

The test PASSES if all checklist items are verified.
The test FAILS if any baseline failure pattern is observed.
