#!/bin/bash

TOTAL=32
CONFIG=examples/p013r030/p013r030.yaml

for i in $(seq 1 $TOTAL); do
    echo "Running job $i / $TOTAL"
    # "2>&1" redirects messages from "stderr" to "stdout"
    # "&" starts process in the background
    # "tee -a" logs the messages to a file
    yatsm -v line $CONFIG $i $TOTAL 2>&1 | tee -a submit_log_${i}_${TOTAL}.log &
done
