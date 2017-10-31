# EVO-ODAS Testing and Benchmarking tool

To start jMeter with the workbench:

```bash
jmeter -q user.properties -t benchmark.jmx -l benchmark.jtl
jmeter -q user.properties -t ceos.jmx -l ceos.jtl
jmeter -q user.properties -t evo-odas-tn.jmx -l evo-odas-tn.jtl
```

## benchmark.jmx

### Adjusting settings

The input CSV file can be adjusted using the "User Defined Variables"
`request_parameters_csv` setting. When the CSV file has no header, use the
`request_parameters_names` setting to set the comma-separated list of parameters.

Currently supported parameters are:
    - `layer`
    - `bbox`
    - `time`
    - `cloudCover`
    - `orbitDirection`

### Running the test suite

Click on the `Start` button on the toolbar to start the testing. The test
results are displayed in the "View Results Tree" and "Summary Report" items
in both "Thread Group"s.

The test is conducted in the following manner: for each row in the specified
CSV, an OpenSearch request as well as a WMS request for GeoServer and
EOxServer is generated, sent, and checked for a successful response indicated
by a HTTP status code of 200.

In both OpenSearch responses, the result is checked and the  total result
count is extracted. Then both counts are compared. When the numbers diverge,
the test fails.

The two corresponding WMS responses are compared in size and marked failed if
the size differs by more than 10%.
