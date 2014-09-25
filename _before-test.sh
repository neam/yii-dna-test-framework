#!/bin/bash

set -x;

echo "Note: When running or sourcing this script, you must reside within the tests folder of the component you want to test"

if [ "$0" == "-bash" ]; then
    echo "Assuming running sourced from within web container"
    $script_path=$(pwd)
else
    script_path=`dirname $0`
    cd $script_path
    # fail on any error
    set -o errexit
fi

export TESTS_BASEPATH=$(pwd)
export TESTS_FRAMEWORK_BASEPATH=$(pwd)/../../core/tests

# run composer install on both app and tests directories
cd $TESTS_BASEPATH/..
php composer.phar install --prefer-source
cd $TESTS_FRAMEWORK_BASEPATH
php ../composer.phar install --prefer-source

# defaults

if [ "$COVERAGE" == "" ]; then
    export COVERAGE=full
fi

cd $TESTS_BASEPATH
../app/yiic config exportDbConfig --connectionID=dbTest | tee /tmp/config.sh
../app/yiic config exportEnvbootstrapConfig --connectionID=dbTest | tee -a /tmp/config.sh
source /tmp/config.sh
echo "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;" | mysql -h$DB_HOST -P$DB_PORT -u$DB_USER --password=$DB_PASSWORD

cd $TESTS_FRAMEWORK_BASEPATH
erb $TESTS_FRAMEWORK_BASEPATH/codeception.yml.erb > $TESTS_BASEPATH/codeception.yml

cd $TESTS_BASEPATH
./generate-local-codeception-config.sh

cd $TESTS_FRAMEWORK_BASEPATH
vendor/bin/codecept build

# leave user at original pwd
cd $TESTS_BASEPATH
