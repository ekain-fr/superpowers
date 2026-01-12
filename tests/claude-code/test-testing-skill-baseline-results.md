# Testing Skill Baseline Test Results

**Test Date:** 2026-01-12
**Scenario:** Post-implementation, testing plan exists, proceed to finishing-branch
**Skill Loaded:** None (baseline test)

---

## Predicted Agent Behavior

Based on known agent behavior patterns without explicit testing guidance, the following failures are expected when running the baseline scenario.

### Primary Failure Mode: Skip Testing Entirely

**Most likely choice:** Agent proceeds directly to finishing-a-development-branch without running the testing phase.

**Predicted verbatim response pattern:**
```
"All implementation tasks are complete. The next step is to proceed to
finishing-a-development-branch. Let me invoke that skill now to wrap up
this feature..."
```

**Rationalization:** The scenario says "Your next step is to proceed to finishing-a-development-branch" - agent takes this literally and skips testing entirely.

---

## Observed Failure Patterns (Predicted)

### Failure 1: Direct Skip to Finish

**Choice:** Skip testing, proceed to finishing-branch
**Rationalization:** "The implementation plan is complete. All tasks were implemented with TDD, so tests are already passing. Let me proceed to finish the branch."

**Why this happens:**
- Goal proximity bias - finish line is visible
- Sunk cost - testing feels like "extra" work
- TDD confusion - agent conflates unit tests from implementation with integration/e2e/regression tests

### Failure 2: Acknowledge Testing Plan, Don't Execute It

**Choice:** Mention testing plan exists but don't run it
**Rationalization:** "I see there's a testing plan at docs/plans/2026-01-12-feature-testing.md. The implementation was done with TDD, so core functionality is tested. I'll proceed to finishing-a-development-branch."

**Why this happens:**
- Testing plan existence != testing plan execution
- No explicit "you MUST execute this plan" instruction
- Agent treats acknowledgment as action

### Failure 3: Partial Test Execution

**Choice:** Run only some test categories
**Rationalization:** "Let me run the existing tests to make sure nothing broke. [runs regression tests only] All passing. Now I can finish the branch."

**Gaps:**
- Skipped writing new integration tests (3 specified)
- Skipped writing new e2e tests (2 specified)
- Only ran regression, not integration or e2e

**Why this happens:**
- Running existing tests is easier than writing new ones
- Multiple test categories create cognitive load
- Agent takes path of least resistance

### Failure 4: No Fix-Retest Loop

**Choice:** Run tests, failures found, proceed anyway
**Rationalization:** "Running tests... 2 failures found. These appear to be minor issues that can be addressed in a follow-up PR. Proceeding to finish the branch."

**Gaps:**
- No fix dispatch for failures
- No re-run after fixes
- No diagnostic report generated
- No human decision point for remaining failures

**Why this happens:**
- Fixing is work, skipping is easy
- No explicit requirement to fix before proceeding
- "Follow-up PR" is convenient escape hatch

### Failure 5: No Diagnostic Report

**Choice:** Run tests but don't generate report
**Rationalization:** "Tests complete. 18/20 passing. Proceeding to finish the branch."

**Gaps:**
- No structured pass/fail summary
- No coverage analysis
- No failure details with logs
- No fix recommendations
- Nothing saved to file for later reference

**Why this happens:**
- Report generation is extra work
- Results are "known" from running tests
- No explicit requirement to save report

---

## Summary: Baseline Failure Categories

| Failure | Frequency | Severity |
|---------|-----------|----------|
| Skip testing entirely | High | Critical |
| Acknowledge plan but don't execute | High | Critical |
| Skip writing new tests | High | High |
| Run only regression (skip integration/e2e) | Medium | High |
| Skip fix-retest loop | Medium | High |
| No diagnostic report | High | Medium |
| No human decision at max iterations | Medium | Medium |

---

## Rationalizations Catalog (Predicted)

These rationalizations need explicit counters in the testing skill:

1. **"TDD already covered this"**
   - Reality: TDD covers unit tests during implementation. Integration, e2e, and regression tests are different.

2. **"Implementation tasks are complete"**
   - Reality: Implementation complete != testing complete. Testing is a separate phase.

3. **"All tests passing"** (after running only some tests)
   - Reality: Must run ALL test categories: integration, e2e, AND regression.

4. **"Minor failures can be addressed in follow-up"**
   - Reality: Failures must be fixed before finishing branch. That's the whole point of testing phase.

5. **"Tests were already run during development"**
   - Reality: Integration and e2e tests are written and run AFTER implementation, not during.

6. **"The testing plan exists, so testing was considered"**
   - Reality: Plan existence != plan execution. Execute the plan.

---

## What the Testing Skill Must Address

Based on these baseline failures, the testing skill must:

1. **Explicit trigger:** "After all implementation tasks complete, BEFORE finishing-branch"
2. **Mandatory plan execution:** "Read and execute the testing plan"
3. **All categories required:** "Run integration tests, e2e tests, AND regression tests"
4. **New test writing required:** "Write all new tests specified in the plan"
5. **Fix-retest loop enforced:** "Fix failures, re-run ALL tests, repeat until pass or max iterations"
6. **Report generation required:** "Generate and save diagnostic report"
7. **Human decision point:** "At max iterations, present Block/Proceed choice"
8. **Counter rationalizations:** Explicit table addressing each excuse

---

## Test Success Criteria

When re-running this scenario WITH the testing skill loaded, agent should:

- [ ] NOT proceed directly to finishing-branch
- [ ] Load and read the testing plan
- [ ] Write all 3 integration tests
- [ ] Write all 2 e2e tests
- [ ] Run regression tests on impacted module
- [ ] Generate diagnostic report with pass/fail counts
- [ ] If failures: dispatch fix subagents
- [ ] After fixes: re-run ALL tests (not just failed ones)
- [ ] At max iterations: present human decision
- [ ] Only then proceed to finishing-branch

These criteria will be verified in the GREEN phase (test-testing-skill-verify.md).
