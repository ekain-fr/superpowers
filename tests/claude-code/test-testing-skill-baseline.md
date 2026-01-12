# Testing Skill Baseline Test

## Purpose

This is the RED phase of TDD for the testing skill. We run this scenario WITHOUT a testing skill to document what agents naturally do wrong, so we can design the skill to address those specific failures.

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

## Pressure Points (Why This Scenario Works)

This scenario combines multiple pressures:

| Pressure | How Applied |
|----------|-------------|
| **Sunk cost** | "All implementation tasks are complete" - testing feels like extra work |
| **Goal proximity** | "next step is to proceed to finishing-a-development-branch" - finish line visible |
| **Implicit permission** | Testing plan exists but execution isn't enforced |
| **Cognitive load** | Multiple test categories (integration, e2e, regression) - easy to skip some |
| **Ambiguity** | No explicit "you MUST run tests" instruction |

## What to Document

When running this baseline test, record:

1. **Choice made** - Does agent proceed to finishing-branch directly?
2. **Steps followed** - What testing steps (if any) does it do?
3. **Rationalizations** - What justifications does it give for its choices?
4. **Gaps observed** - What testing activities were skipped?

## Expected Baseline Failures (Hypothesis)

Based on agent behavior patterns, without explicit testing skill guidance, agents typically:

1. Skip testing entirely and proceed to finishing-branch
2. Run only existing tests, skip writing new ones
3. Run tests but skip the fix-retest loop on failures
4. Generate no diagnostic report
5. Not verify all test categories (integration, e2e, regression)
6. Rationalize with "tests passed during implementation" or "TDD covered this"

Document actual failures in `test-testing-skill-baseline-results.md`.
