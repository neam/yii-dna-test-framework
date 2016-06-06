#!/bin/bash

set -x;

echo "Note: When sourcing this script, you must reside within the tests folder of the component you want to test"

echo "Assuming running sourced"
script_path=$(pwd)

if [ "$(cd $script_path/..;basename $(pwd))" == "dna" ]; then
    # assume we are testing the dna
    export PROJECT_BASEPATH=$(pwd)/../..
else
    # assume we are testing a yiiapp under yiiapps/
    export PROJECT_BASEPATH=$(pwd)/../../..
fi

export TESTS_BASEPATH=$(pwd)
export TESTS_FRAMEWORK_BASEPATH=$PROJECT_BASEPATH/vendor/neam/yii-dna-test-framework
export TESTS_BASEPATH_REL=$(python -c "import os.path; print os.path.relpath('$TESTS_BASEPATH', '$TESTS_FRAMEWORK_BASEPATH')")

# defaults

if [ "$COVERAGE" == "" ]; then
    export COVERAGE=full
fi

cd $PROJECT_BASEPATH
source vendor/neam/php-app-config/shell-export.sh
cd -

cd $TESTS_FRAMEWORK_BASEPATH
erb $TESTS_FRAMEWORK_BASEPATH/codeception.yml.erb > $TESTS_BASEPATH/codeception.yml

cd $TESTS_BASEPATH
./generate-local-codeception-config.sh
$TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept build

# function codecept for easy access to codecept binary
function codecept () {
    $TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept $@
}
export -f codecept
# helper functions
function activate_test_config () {
    sed -i 's/#CONFIG_ENVIRONMENT=test/CONFIG_ENVIRONMENT=test/g' $PROJECT_BASEPATH/.env
}
export -f activate_test_config
function inactivate_test_config () {
    sed -i 's/CONFIG_ENVIRONMENT=test/#CONFIG_ENVIRONMENT=test/g' $PROJECT_BASEPATH/.env
}
export -f inactivate_test_config
function test_console () {
    $PROJECT_BASEPATH/vendor/bin/yii-dna-pre-release-testing-console $@
}
export -f test_console
function stop_api_mock_server () {
    pid=$(ps aux | grep node/bin/api-mock | grep -v grep | head -n 1 | awk '{ print $2 }')
    if [ "$pid" != "" ]; then
        kill $pid
    fi
}
export -f stop_api_mock_server
function start_api_mock_server () {
    installed=$(which api-mock || true)
    if [ "$installed" == "" ]; then
        npm -g install api-mock
    fi
    stop_api_mock_server
    api-mock $@ --port 3000 &
}
export -f start_api_mock_server
