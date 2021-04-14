#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

xsv cat rows <( xsv select 1,2,4 $BOSTON_REQUESTS_CSV ) <( xsv select 1,2,4 $POLICE_REQUESTS_CSV )  > /tmp/all_old_files.csv
xsv cat rows target/City_of_Boston_Public_Records_Requests_20*Redacted.csv > /tmp/all_new_files.csv
xsv join --left "Reference No" /tmp/all_new_files.csv "Reference No" /tmp/all_old_files.csv | xsv select '1,9,2,3,10,4-7'
