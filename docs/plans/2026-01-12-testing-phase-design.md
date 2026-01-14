# Testing Phase Design

**Goal:** Add a comprehensive Testing phase to the superpowers workflow that catches integration issues, regressions, and coverage gaps before code is merged.

**Problem:** Current workflow has TDD unit tests baked into implementation, but:
- Missing integration tests - unit tests pass but feature doesn't work end-to-end
- Regression blindness - changes break existing features not directly tested
- Test coverage gaps - TDD covers happy path but misses edge cases across system

---

## Workflow Changes

**New workflow:**

```
brainstorming → writing-plans → executing-plans → testing → finishing-branch
     ↓               ↓                                ↓
 + testing      + testing plan              new skill that:
   scenarios      file generated            - executes tests
   + impacted                               - reports diagnostics
   modules                                  - auto-dispatches fixes
   + max iters                              - loops until pass/max
```

**Files affected:**
- **Create:** `skills/executing-tests/SKILL.md` - new testing phase skill
- **Modify:** `skills/brainstorming/SKILL.md` - add testing sections to design output
- **Modify:** `skills/writing-plans/SKILL.md` - generate testing plan file
- **Modify:** `skills/executing-plans/SKILL.md` - call testing skill before finishing-branch
- **Modify:** `skills/subagent-driven-development/SKILL.md` - call testing skill before finishing-branch

---

## Brainstorming Skill Changes

**New sections added to design document output:**

```markdown
## Testing Strategy

### Final Testing Scenarios
<!-- New features that need integration/e2e tests -->
1. [Scenario]: [What to test] → [Expected outcome]
2. ...

### Impacted Modules
<!-- Existing modules that need regression tests -->
- `path/to/module` - [Why impacted: uses X, shares Y]
- ...

### Testing Configuration
- Max fix iterations: [3-5, default 3]
```

**Where this fits:**
After design sections (architecture, components, data flow, error handling), before Documentation section.

**Validation questions to ask:**
- "What user flows should work end-to-end after this feature?"
- "What existing functionality might this change affect?"
- Max fix iterations (recommend 3, explain 3-5 range)

---

## Writing-Plans Skill Changes

**New output:** Generates `docs/plans/YYYY-MM-DD-<feature>-testing.md` alongside implementation plan.

**Testing plan structure:**

```markdown
# [Feature Name] Testing Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-tests to execute this plan.

**Goal:** [One sentence describing what testing validates]

**Max Fix Iterations:** [N from design doc]

**Source Design:** `docs/plans/YYYY-MM-DD-<feature>-design.md`

---

## Integration Tests

### Test 1: [Component interaction being tested]
**Files:**
- Create: `tests/integration/path/to/test.py`

**Step 1: Write the test**
```python
def test_components_work_together():
    # setup, action, assertion
```

**Step 2: Run test**
Run: `pytest tests/integration/path/to/test.py -v`
Expected: PASS (after implementation complete)

---

## End-to-End Tests

### Test 1: [User flow being tested]
**Files:**
- Create: `tests/e2e/path/to/test.py`

**Step 1: Write the test**
...

---

## Regression Tests

### Module: `path/to/impacted/module`
**Reason:** [Why this module might be affected]

**Step 1: Identify existing tests**
Run: `pytest tests/ -v --collect-only | grep module_name`

**Step 2: Run regression suite**
Run: `pytest tests/path/to/module/ -v`
Expected: All PASS
```

**Key principles:**
- Same bite-sized task format as implementation plan
- Tests reference actual code paths from implementation plan
- Regression tests point to existing test files, not new ones

---

## New Testing Skill - Core Process

**File:** `skills/executing-tests/SKILL.md`

**Trigger:** Called by executing-plans after all implementation tasks complete, before finishing-branch.

**Core process:**

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Load Testing Plan                                    │
│ - Read docs/plans/YYYY-MM-DD-<feature>-testing.md           │
│ - Extract max iterations config                              │
│ - Create TodoWrite for test tasks                            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Execute Tests                                        │
│ - Write any new test files (integration, e2e)               │
│ - Run all test categories:                                   │
│   • Integration tests                                        │
│   • End-to-end tests                                         │
│   • Regression tests (existing test suites)                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Generate Diagnostic Report                           │
│ - Pass/fail summary per category                             │
│ - Coverage analysis                                          │
│ - Failure details with logs                                  │
│ - Fix recommendations                                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
              ┌───────────────┴───────────────┐
              │ All tests pass?               │
              └───────────────┬───────────────┘
                     yes │           │ no
                         ↓           ↓
              ┌──────────────┐  ┌──────────────────────┐
              │ Step 6:      │  │ Step 4: Dispatch     │
              │ Complete     │  │ fix subagents        │
              └──────────────┘  └──────────────────────┘
                                         ↓
                                ┌──────────────────────┐
                                │ Step 5: Re-run ALL   │
                                │ tests, increment iter│
                                └──────────────────────┘
                                         ↓
                              ┌──────────────────────┐
                              │ iter < max?          │
                              └──────────┬───────────┘
                                  yes │       │ no
                                      ↓       ↓
                              (back to Step 3) │
                                              ↓
                              ┌──────────────────────┐
                              │ Human decision:      │
                              │ Block or proceed?    │
                              └──────────────────────┘
```

---

## Diagnostic Report Format

**Report structure (displayed to user and saved to file):**

```markdown
# Test Report: [Feature Name]
**Iteration:** [N] of [max]
**Timestamp:** [ISO timestamp]

## Summary
| Category      | Pass | Fail | Skip | Total |
|---------------|------|------|------|-------|
| Integration   |  3   |  1   |  0   |   4   |
| End-to-End    |  2   |  0   |  0   |   2   |
| Regression    |  15  |  2   |  1   |   18  |
| **Total**     |  20  |  3   |  1   |   24  |

## Coverage Analysis
- New code paths tested: [X/Y]
- Impacted modules with passing regression: [A/B]
- Gaps identified: [list any untested paths]

## Failures

### FAIL: test_integration_auth_flow
**File:** `tests/integration/auth/test_flow.py:45`
**Error:**
```
AssertionError: Expected 200, got 401
  response = client.post('/api/login', data=creds)
  assert response.status_code == 200
```
**Logs:**
```
[DEBUG] Auth service: invalid token format
```
**Recommendation:** Check token generation in `src/auth/tokens.py:23`

### FAIL: test_regression_user_profile
...

## Next Steps
- [ ] Fix: test_integration_auth_flow (dispatching subagent)
- [ ] Fix: test_regression_user_profile (dispatching subagent)
```

**Report saved to:** `docs/plans/YYYY-MM-DD-<feature>-test-report.md` (overwritten each iteration)

---

## Fix Dispatch Mechanism

For each failure, testing skill:

1. **Creates fix task** with context:
   - Test file and line number
   - Error message and logs
   - Recommendation from report
   - Relevant source file paths

2. **Dispatches subagent** using Task tool:
   ```
   Task(subagent_type="general-purpose", prompt="""
   Fix failing test: test_integration_auth_flow

   **Error:** AssertionError: Expected 200, got 401
   **Test file:** tests/integration/auth/test_flow.py:45
   **Likely source:** src/auth/tokens.py:23
   **Recommendation:** Check token generation

   Instructions:
   1. Read the test to understand expected behavior
   2. Read the source file to find the bug
   3. Fix the source code (not the test)
   4. Run the specific test to verify fix
   5. Do NOT run full test suite (testing skill handles that)
   """)
   ```

3. **Parallel vs sequential:**
   - Independent failures: dispatch in parallel
   - Related failures (same source file): dispatch sequentially

4. **After all fixes complete:**
   - Re-run ALL tests
   - Generate new diagnostic report
   - Increment iteration counter

---

## Max Iterations & Human Decision Point

**When max iterations reached with remaining failures:**

```
Max fix iterations (3) reached. 2 tests still failing.

## Remaining Failures
1. test_integration_auth_flow - token format issue
2. test_regression_user_profile - field validation

## Options
1. **Block** - Cannot proceed until these are fixed manually
2. **Proceed with warnings** - Continue to finishing-branch, failures noted in PR description

Which option?
```

**If Block:** Testing skill stops, user fixes manually, re-invoke when ready.

**If Proceed:** Completes with "passed_with_warnings", finishing-branch includes in PR:
```markdown
## Known Issues
- [ ] test_integration_auth_flow - token format issue
- [ ] test_regression_user_profile - field validation

These failures could not be auto-resolved after 3 fix iterations.
```

---

## Executing-Plans Integration

**Current Step 5:** All tasks complete → finishing-a-development-branch

**New Step 5:** All tasks complete → testing skill → finishing-a-development-branch

**Changes:**

```markdown
### Step 5: Run Testing Phase

After all implementation tasks complete and verified:
- Announce: "I'm using the testing skill to validate the implementation."
- **REQUIRED SUB-SKILL:** Use superpowers:executing-tests
- Pass testing plan path: `docs/plans/YYYY-MM-DD-<feature>-testing.md`

**If testing completes (all pass or proceed-with-warnings):**
- Continue to Step 6

**If testing blocks:**
- Stop execution
- Report: "Testing blocked. Fix remaining issues and re-run /executing-tests."

### Step 6: Complete Development
(formerly Step 5 - unchanged)
```

Also update `subagent-driven-development` similarly.

---

## Edge Cases

1. **No testing plan exists** - Prompt user to generate one or skip
2. **No failures on first run** - Skip fix loop, proceed to completion
3. **Fix introduces new failures** - Caught by re-running ALL tests
4. **Subagent fix fails** - Captured in next test run's report
5. **User cancels mid-testing** - State preserved, resume with `/executing-tests`

---

## Out of Scope (YAGNI)

- Flaky test detection/retry
- Test parallelization optimization
- Code coverage percentage thresholds
- Custom test frameworks beyond standard runners

---

## Implementation Notes

**Respect writing-skills TDD process:**

For each skill (new testing skill + modifications):
1. **RED:** Run pressure scenarios WITHOUT the skill, document baseline failures
2. **GREEN:** Write minimal skill addressing specific violations observed
3. **REFACTOR:** Close loopholes found in testing, re-verify

Test categories for the new testing skill:
- Technique skill: test application scenarios, variation scenarios, missing information
- Success criteria: Agent successfully executes testing plan, dispatches fixes, produces report
