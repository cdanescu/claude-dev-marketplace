#!/bin/bash

# Generic PHPUnit Test Runner with Coverage
# Runs tests through pl-dev Docker container
# Works across multiple projects (subscriptionsite.base, Giraffe, etc.)

# Configuration
CONTAINER_NAME="pl-dev"
DOCKER_BASE_PATH="/local/dev"
BOOTSTRAP_PATH="/local/dev/Platform/Include/unitTestBootstrap.php"
PHPUNIT_BIN="/local/dev/Platform/Lib/phpunit.phar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current project directory name
PROJECT_NAME=$(basename "$PWD")
echo -e "${GREEN}Project: ${PROJECT_NAME}${NC}"

# Validate we're in a project directory with Tests folder
if [[ ! -d "$PWD/Tests" ]]; then
    echo -e "${RED}Error: No Tests directory found in current directory${NC}"
    echo "Please run this script from a project root (e.g., subscriptionsite.base, Giraffe)"
    exit 1
fi

# Check if Docker container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Docker container '${CONTAINER_NAME}' is not running${NC}"
    echo "Please start the container with: docker start ${CONTAINER_NAME}"
    exit 1
fi

echo -e "${GREEN}Docker container '${CONTAINER_NAME}' is running${NC}"

# Parse arguments
COVERAGE=true
TEST_PATH=""
RUN_ALL_DIRS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-coverage)
            COVERAGE=false
            shift
            ;;
        *)
            # This is the test path (relative to project root)
            TEST_PATH="$1"
            # Remove leading slash if present
            TEST_PATH="${TEST_PATH#/}"
            shift
            ;;
    esac
done

# If no test path specified, run all top-level directories in Tests/
if [[ -z "$TEST_PATH" ]]; then
    RUN_ALL_DIRS=true
    echo -e "${YELLOW}No test path specified - will run all top-level test directories separately${NC}"
fi

# Build Docker paths
DOCKER_PROJECT_PATH="${DOCKER_BASE_PATH}/${PROJECT_NAME}"
DOCKER_TEST_PATH="${DOCKER_PROJECT_PATH}/${TEST_PATH}"

# Build phpunit command arguments
PHPUNIT_ARGS="--verbose --testdox --debug --disallow-test-output"
PHPUNIT_ARGS+=" --bootstrap ${BOOTSTRAP_PATH}"

# Add log files
TIMESTAMP=$(date +%s)
TMP_JUNIT="/tmp/phpunit_${PROJECT_NAME}_${TIMESTAMP}_junit.xml"
TMP_JSON="/tmp/phpunit_${PROJECT_NAME}_${TIMESTAMP}_json.json"
PHPUNIT_ARGS+=" --log-junit ${TMP_JUNIT}"
PHPUNIT_ARGS+=" --log-json ${TMP_JSON}"

# Add coverage if enabled
if [[ "$COVERAGE" == true ]]; then
    COVERAGE_HTML="/tmp/coverage_${PROJECT_NAME}_${TIMESTAMP}"
    PHPUNIT_ARGS+=" --coverage-html ${COVERAGE_HTML}"
    PHPUNIT_ARGS+=" --coverage-text"
    echo -e "${YELLOW}Coverage: ENABLED${NC}"
    echo "HTML coverage will be saved to: ${COVERAGE_HTML}"
else
    echo -e "${YELLOW}Coverage: DISABLED${NC}"
fi

# Function to run tests for a single path
run_tests() {
    local test_path=$1
    local docker_test_path="${DOCKER_PROJECT_PATH}/${test_path}"
    local local_test_path="${PWD}/${test_path}"

    echo -e "${GREEN}Test path: ${test_path}${NC}"
    echo "Docker path: ${docker_test_path}"

    # Detect if path is a file or directory
    if [[ -f "${local_test_path}" ]]; then
        TEST_TYPE="file"
        PHPUNIT_TEST_ARG="UnitTest ${docker_test_path}"
    elif [[ -d "${local_test_path}" ]]; then
        TEST_TYPE="directory"
        PHPUNIT_TEST_ARG="${docker_test_path}"
    else
        echo -e "${RED}Error: Test path '${test_path}' does not exist${NC}"
        return 1
    fi

    echo "Test type: ${TEST_TYPE}"
    echo ""
    echo "========================================"
    echo "Starting PHPUnit Tests"
    echo "========================================"
    echo ""

    # Run the tests through Docker
    docker exec ${CONTAINER_NAME} ${PHPUNIT_BIN} ${PHPUNIT_ARGS} ${PHPUNIT_TEST_ARG}

    return $?
}

# Main execution
OVERALL_RESULT=0

if [[ "$RUN_ALL_DIRS" == true ]]; then
    # Run each top-level directory separately
    TEST_DIRS=$(ls -d Tests/*/ 2>/dev/null | sed 's|/$||')

    if [[ -z "$TEST_DIRS" ]]; then
        echo -e "${RED}Error: No test directories found in Tests/${NC}"
        exit 1
    fi

    echo ""
    echo "========================================"
    echo "Running Tests by Directory"
    echo "========================================"

    TOTAL_DIRS=0
    PASSED_DIRS=0
    FAILED_DIRS=0

    for dir in $TEST_DIRS; do
        ((TOTAL_DIRS++))
        echo ""
        echo "######################################## "
        echo "# Directory $TOTAL_DIRS: $dir"
        echo "########################################"
        echo ""

        if run_tests "$dir"; then
            ((PASSED_DIRS++))
            echo -e "${GREEN}✓ $dir PASSED${NC}"
        else
            ((FAILED_DIRS++))
            OVERALL_RESULT=1
            echo -e "${RED}✗ $dir FAILED${NC}"
        fi
    done

    echo ""
    echo "========================================"
    echo "Overall Test Results"
    echo "========================================"
    echo "Total directories: $TOTAL_DIRS"
    echo -e "${GREEN}Passed: $PASSED_DIRS${NC}"
    if [[ $FAILED_DIRS -gt 0 ]]; then
        echo -e "${RED}Failed: $FAILED_DIRS${NC}"
    else
        echo "Failed: 0"
    fi

else
    # Run single path
    if run_tests "$TEST_PATH"; then
        OVERALL_RESULT=0
        echo ""
        echo "========================================"
        echo "Test Results"
        echo "========================================"
        echo -e "${GREEN}Tests PASSED${NC}"
    else
        OVERALL_RESULT=$?
        echo ""
        echo "========================================"
        echo "Test Results"
        echo "========================================"
        echo -e "${RED}Tests FAILED (exit code: ${OVERALL_RESULT})${NC}"
    fi
fi

# Output coverage location again if enabled
if [[ "$COVERAGE" == true ]]; then
    echo ""
    echo -e "${GREEN}Coverage report saved to:${NC}"
    echo "  ${COVERAGE_HTML}/index.html"
    echo ""
    echo "Open with: open ${COVERAGE_HTML}/index.html"
fi

echo ""
echo "Log files:"
echo "  JUnit XML: ${TMP_JUNIT}"
echo "  JSON: ${TMP_JSON}"

exit $OVERALL_RESULT
