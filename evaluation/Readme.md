# EVO-ODAS Benchmarking tool

To start jMeter with the workbench:

jmeter -t benchmark.jmx


## Adjusting settings

The input CSV file can be adjusted using the "User Defined Variables"
`request_parameters_csv` setting. When the CSV file has no header, use the 
`request_parameters_names` setting to set the comma-separated list of parameters.

Currently supported parameters are: 
    - `layer`
    - `bbox`
    - `time`
    - `cloudCover`
    - `orbitDirection`

## Running the test suite

Click on the `Start` button on the toolbar to start the testing. The test
results are displayed in the "View Results Tree" item in the "Thread Group".

The test is conducted in the following manner: for each row in the specified
CSV, a request for GeoServer and EOxServer is generated. In both responses, the 
result is checked and the total result count is extracted. Then both counts are
compared. When the numbers diverge, the test fails.

