#!/bin/bash

TOTAL=16
CONFIG=/home/eline91/shared/userdata3/cleanFiles_testArea/1_testArea.yaml

for i in $(seq 1 $TOTAL); do
    echo "Running job $i / $TOTAL"
    # "2>&1" redirects messages from "stderr" to "stdout"
    # "&" starts process in the background
    # "tee -a" logs the messages to a file
    yatsm -v line $CONFIG $i $TOTAL 2>&1 | tee -a /home/eline91/shared/userdata3/logFiles/submit_log_${i}_${TOTAL}.log &
done
