# dev-tools-cms

Development tools and commands for CMS projects using PHP 5.6 and PHPUnit.

## Requirements

Before using this plugin, ensure you have the following:

1. **PHP 5.6 Environment**: Your project must be configured to run with PHP 5.6
2. **Tests Directory**: A `Tests/` directory at the root level of your project
3. **Docker Container**: The `pl-dev` Docker container must be running
4. **Project Structure**: Compatible with projects like subscriptionsite.base, Giraffe, etc.

### Docker Container Setup

The plugin expects a Docker container named `pl-dev` with:
- Mount path: `/local/dev`
- PHPUnit binary: `/local/dev/Platform/Lib/phpunit.phar`
- Bootstrap file: `/local/dev/Platform/Include/unitTestBootstrap.php`

Start the container before running tests:
```bash
docker start pl-dev
```

## Commands

### `/test` - Run PHPUnit Tests with Coverage

Runs PHPUnit tests through the pl-dev Docker container in the background, allowing you to continue working while tests execute.

#### Usage Examples

**Run all tests** (recommended - runs each top-level directory separately):
```
/test
```

**Run specific test directory**:
```
/test Tests/Cms
```

**Run specific test subdirectory**:
```
/test Tests/Cms/Service/Partner
```

**Run single test file**:
```
/test Tests/Cms/Service/PartnerTest.php
```

**Disable coverage for faster execution**:
```
/test --no-coverage
```

**Combine flags and paths**:
```
/test --no-coverage Tests/Cms
```

#### How It Works

When you run `/test` without arguments, the command will:
1. Detect all top-level directories in `Tests/` (e.g., Tests/Api, Tests/Cms, Tests/Community)
2. Run each directory separately to avoid class name conflicts and redeclaration errors
3. Generate a combined coverage report
4. Report pass/fail status for each directory

The command spawns a background agent that:
- Navigates to your project directory
- Executes the test script through the Docker container
- Monitors progress (full test suites may take 10+ minutes)
- Reports final results including coverage location

#### Output

Test results include:
- Pass/fail status for each test directory
- Code coverage report (HTML format) saved to `/tmp/coverage_[project]_[timestamp]/`
- JUnit XML and JSON logs in `/tmp/`

To view coverage:
```bash
open /tmp/coverage_[project]_[timestamp]/index.html
```

## Installation

This plugin is available through the claude-dev-marketplace. Install it using the Claude Code marketplace system.

## Project Compatibility

This plugin works across multiple CMS projects including:
- subscriptionsite.base
- Giraffe
- Any project with a `Tests/` directory and pl-dev Docker setup

## Troubleshooting

**Error: No Tests directory found**
- Ensure you're running the command from the project root directory

**Error: Docker container 'pl-dev' is not running**
- Start the container: `docker start pl-dev`

**Class redeclaration errors**
- Use `/test` without arguments to run directories separately
- Avoid running the entire Tests/ directory at once
