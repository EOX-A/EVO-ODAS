#!/bin/bash

USER_PROPERTIES="user_internal.properties"
PUBLISH_DIR="/oda/repository/testplan/"
#TESTS="ceos"
#TESTS="performance wcs ceos evo-odas-tn benchmark"
TESTS="ceos evo-odas-tn wcs benchmark"
EXT_LIST="csv html jmx jtl log"

for test in $TESTS; do 
    echo "*********************************"
    echo "Running $test tests.."

    echo "[$test] Cleaning old files.."
    rm ${test}.html ${test}.jtl ${test}.log 2> /dev/null

    echo "[$test] Starting JMeter.."
    jmeter -n -q $USER_PROPERTIES -t ${test}.jmx -l ${test}.jtl -j ${test}.log && \

    echo "[$test] Generating Report.."
    ant -Djmeter.home=${JMETER_HOME} -Dreport.title="$test Test Report" -Dtest=$test report && \

    echo "[$test] Publishing '$EXT_LIST' Files.."
    for ext in $EXT_LIST; do
        cp ${test}.${ext} $PUBLISH_DIR
    done

done
