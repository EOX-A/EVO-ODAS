#!/bin/bash

# Default settings
USER_PROPERTIES="user.properties"
USER_PROPERTIES="user_internal.properties"
PREPARATION_DIR="../test_data_preparation"
PUBLISH_DIR="/oda/repository/testreport"
BASE_URL="oda.dlr.de"
BASE_URL="ows-oda.eoc.dlr.de"
#TESTS="ceos performance"
#TESTS="ceos evo-odas-tn wcs performance benchmark"
#TESTS="ceos evo-odas-tn"
TESTS="wcs"
PARTS="3"
DATASETS="sentinel-1 sentinel-2"
#DATASETS="sentinel-2"
USERS="1"
SCALE="1"

# Parse command line arguments
while getopts "c:t:p:s:u:d:" opt; do
   case $opt in
    c)  USER_PROPERTIES="$OPTARG"; ;;
    t)   TESTS="$OPTARG"; ;;
    p)  PARTS="$OPTARG"; ;;
    s)  SCALE="$OPTARG"; ;;
    u)  USERS="$OPTARG"; ;;
    d)  DATASETS="$OPTARG"; ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

echo "############################################"
echo "# USER_PROPERTIES: $USER_PROPERTIES"
echo "# TESTS: $TESTS"
echo "# PARTS: $PARTS"
echo "# SCALE: $SCALE"
echo "# USERS: $USERS"
echo "# DATASETS: $DATASETS"
echo "############################################"
echo
echo "*********************************"
echo "Generating test data with $PARTS part(s).."
for dataset in $DATASETS; do
    cd $PREPARATION_DIR
    if [ -r "${dataset}.yaml" ]; then
        request_csv="requests_${dataset}_${PARTS}.csv"
        echo "Generating ${dataset} input requests.."
        python generate_requests.py --randomize --parts $PARTS ${dataset}.yaml > $request_csv
    else
        echo "WARNING: No such dataset found: $dataset"
    fi
    cd  - > /dev/null
    cp $PREPARATION_DIR/${request_csv} performance_${dataset}.csv
    cp $PREPARATION_DIR/${request_csv} benchmark_${dataset}.csv
done
echo "Generated $(cat $PREPARATION_DIR/${request_csv} | wc -l ) request with $PARTS parts."
echo

echo "*********************************"
echo "Assuming GeoServer Scaled to $SCALE instance(s).."
echo


echo "*********************************"
echo "Publishing global files to ${PUBLISH_DIR}"
echo
cp -p index.html $PUBLISH_DIR
cp user*.properties $PUBLISH_DIR

# Run the tests
export JVM_ARGS="-Xms2g -Xmx2g" 

for test in $TESTS; do

    for dataset in $DATASETS; do

        if [ $test = performance ] || [ $test = benchmark ]; then
            console_title="Running $test tests for $dataset (Scale=$SCALE, Parts=$PARTS, Users=$USERS, URL=$BASE_URL)"
            report_title="${test^^} Test Report for ${dataset^} (Scale=$SCALE, Parts=$PARTS, Users=$USERS, URL=$BASE_URL)"
            out_dir="${PUBLISH_DIR}/${test}/${dataset}/scale-${SCALE}/parts-${PARTS}"
        else
            console_title="Running $test tests (URL=$BASE_URL)"
            report_title="${test^^} Test Report (URL=$BASE_URL)"
            out_dir="${PUBLISH_DIR}/${test}"
        fi

        [[ $dataset = sentinel-2 ]] && \
            eoxserver_wms_enabled="false" || \
            eoxserver_wms_enabled="true"
        #echo "eoxserver_wms_enabled=$eoxserver_wms_enabled"

        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "${console_title}"
        
        echo
        echo "[$test] Cleaning old files.."
        rm ${test}*.out ${test}*.log 2> /dev/null
        
        # File e.g. performance.csv must exist and be readable
        [ -r ${test}_${dataset}.csv ] && cp ${test}_${dataset}.csv ${test}.csv
        echo "[$test] Starting JMeter on '${test}' with '$USERS' users.."
        jmeter -n -p $USER_PROPERTIES -t ${test}.jmx -l ${test}.out -j ${test}.log \
            -J "eoxserver_wms_enabled=$eoxserver_wms_enabled" \
            -J "base_url=$BASE_URL" \
            -J "concurrent_users=$USERS"
        
        report_out_dir="report"
        if [ ! -d $report_out_dir ]; then
            mkdir -p $report_out_dir
        else
            # required by report generator, otherwise the report is not produced
            rm -r $report_out_dir
        fi

        echo "[$test] Generating Report in directory '$report_out_dir'"
        jmeter -p $USER_PROPERTIES -t ${test}.jmx -g "${test}.out" -o "$report_out_dir" \
            -J "jmeter.reportgenerator.report_title=${report_title}"

        mkdir -p ${out_dir}
        echo "[$test] Publishing test files to ${out_dir}"
        cp -rp ${report_out_dir} $out_dir
        cp -p ${test}.csv ${out_dir}
        cp -p ${test}.jmx $out_dir
        cp -p ${test}.out $out_dir 2> /dev/null
        cp -p ${test}_${dataset}.out $out_dir 2> /dev/null
        cp -p ${test}.log $out_dir 2> /dev/null
        cp -p ${test}_${dataset}.log $out_dir 2> /dev/null

        if [ $test = performance ] || [ $test = benchmark ]; then
            echo "Performance or benchmark test detected. Testing next dataset.."
        else
            echo "No performance or benchmark test detected, skipping next dataset.."
            break
        fi
    done
    echo "Done with test: $test"
done
