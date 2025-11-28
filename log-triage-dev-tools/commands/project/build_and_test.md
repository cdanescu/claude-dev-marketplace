---
description: Run npm test for log-triage-service and summarize the results
---

# /project:build_and_test

Run the Node.js project's full test cycle and report status.

Steps:
1. Run `npm test`.
2. If tests fail:
   - Summarize failing files and test names.
   - Quote the error messages briefly.
   - Propose specific code or test changes to fix them.
3. If tests pass:
   - Confirm tests passed.
   - Suggest any obvious next tests or refactors.

Assumptions:
- The project is a Node.js app with Jest configured.
- `npm test` runs the full suite.
