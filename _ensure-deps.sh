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

# run composer install on both app and tests directories
cd $TESTS_BASEPATH/..
php $PROJECT_BASEPATH/composer.phar install --prefer-source --optimize-autoloader
cd $TESTS_FRAMEWORK_BASEPATH
php $PROJECT_BASEPATH/composer.phar install --prefer-source --optimize-autoloader
