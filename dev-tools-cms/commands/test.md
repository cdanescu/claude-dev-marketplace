Run PHPUnit tests in background with coverage.

IMPORTANT: Before executing tests, you MUST use the AskUserQuestion tool to gather user preferences:

1. First Question - Coverage:
   - Question: "Do you want to generate code coverage reports?"
   - Header: "Coverage"
   - Options:
     * "Yes, generate coverage" - Generates HTML coverage report (slower)
     * "No coverage" - Skip coverage for faster execution
   - multiSelect: false

2. Second Question - Test Scope:
   - Question: "Which tests do you want to run?"
   - Header: "Test Scope"
   - Options:
     * "All tests" - Run all top-level test directories separately (recommended)
     * "Specific path" - Run a specific test directory, subdirectory, or file
   - multiSelect: false
   - If user selects "Specific path" or "Other", ask them to provide the path (e.g., Tests/Cms, Tests/Cms/Service/Partner, or Tests/Path/To/File.php)

After gathering user preferences, use the Task tool with the general-purpose agent to execute the `run-phpunit-coverage.sh` script from this plugin's scripts directory in the background.

Script Arguments Based on User Choices:
- No coverage + All tests: (no arguments)
- No coverage + Specific path: `--no-coverage [path]`
- Coverage + All tests: (no arguments)
- Coverage + Specific path: `[path]`

When running all tests (no path specified), the script will:
- Detect all top-level directories in Tests/
- Run each directory separately (avoiding class redeclaration errors)
- Generate a combined coverage report (if coverage enabled)
- Report pass/fail status for each directory

The agent should:
1. Ask the user questions using AskUserQuestion tool
2. Navigate to the current project directory
3. Locate the script in the dev-tools-cms plugin installation (typically in ~/.claude/plugins/marketplaces/claude-dev-marketplace/dev-tools-cms/scripts/run-phpunit-coverage.sh)
4. Execute the script with appropriate arguments based on user choices
5. Monitor the output and report progress (may take 10+ minutes for full suite)
6. Report final results including coverage location when complete

This runs tests through the pl-dev Docker container and works across all projects (subscriptionsite.base, Giraffe, etc.).
