#!/bin/bash

# This script is necessary in order to be able to run the correct set of tests while keeping it easy to annotate which
# tests belongs to which groups within the tests themselves

# set the codeception test group arguments depending on DATA and COVERAGE
if [ "$DATA" == "" ]; then
    echo "Warning: DATA is not properly set (Current value is: '$DATA')"
    DATA="not-set"
fi
MINIMAL_CODECEPTION_GROUP_ARGS="-g data:$DATA,coverage:minimal -g coverage:minimal"
BASIC_CODECEPTION_GROUP_ARGS="-g data:$DATA,coverage:basic -g coverage:basic"
FULL_CODECEPTION_GROUP_ARGS="-g data:$DATA,coverage:full -g coverage:full"
PARANOID_CODECEPTION_GROUP_ARGS="-g data:$DATA,coverage:paranoid -g coverage:paranoid"
case "$COVERAGE" in
    "minimal")
        CODECEPTION_GROUP_ARGS="$MINIMAL_CODECEPTION_GROUP_ARGS"
        ;;
    "basic")
        CODECEPTION_GROUP_ARGS="$MINIMAL_CODECEPTION_GROUP_ARGS $BASIC_CODECEPTION_GROUP_ARGS"
        ;;
    "full")
        CODECEPTION_GROUP_ARGS="$MINIMAL_CODECEPTION_GROUP_ARGS $BASIC_CODECEPTION_GROUP_ARGS $FULL_CODECEPTION_GROUP_ARGS"
        ;;
    "paranoid")
        CODECEPTION_GROUP_ARGS="$MINIMAL_CODECEPTION_GROUP_ARGS $BASIC_CODECEPTION_GROUP_ARGS $FULL_CODECEPTION_GROUP_ARGS $PARANOID_CODECEPTION_GROUP_ARGS"
        ;;
    *)
        echo "Error: COVERAGE is not properly set (Current value is: '$COVERAGE')"
        exit 1
        ;;
esac
echo "CODECEPTION_GROUP_ARGS=$CODECEPTION_GROUP_ARGS"