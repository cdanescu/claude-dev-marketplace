Run PHPUnit tests in background with coverage.

Use the Task tool with the general-purpose agent to execute the `run-phpunit-coverage.sh` script from this plugin's scripts directory in the background. This allows tests to run without blocking the main conversation.

Arguments:
- No arguments: Run all top-level test directories separately (Tests/Api, Tests/Cms, Tests/Community, etc.) to avoid class name conflicts
- `--no-coverage`: Disable coverage reporting for faster execution
- `Tests/Cms`: Run specific test directory with coverage
- `Tests/Cms/Service/Partner`: Run specific subdirectory with coverage
- `Tests/Path/To/File.php`: Run single test file with coverage
- `--no-coverage Tests/Cms`: Combine flags and paths

When running without arguments, the script will:
- Detect all top-level directories in Tests/
- Run each directory separately (avoiding class redeclaration errors)
- Generate a combined coverage report
- Report pass/fail status for each directory

The agent should:
1. Navigate to the current project directory
2. Locate the script in the dev-tools-cms plugin installation (typically in ~/.claude/plugins/marketplaces/claude-dev-marketplace/dev-tools-cms/scripts/run-phpunit-coverage.sh)
3. Execute the script with any provided arguments
4. Monitor the output and report progress (may take 10+ minutes for full suite)
5. Report final results including coverage location when complete

This runs tests through the pl-dev Docker container and works across all projects (subscriptionsite.base, Giraffe, etc.).
