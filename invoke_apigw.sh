#!/bin/bash

# Set the API Gateway endpoint URL
API_GATEWAY_ENDPOINT="<<YOUR API INVOKE URL>>"

# Set the number of invocations
NUM_INVOCATIONS=50

# Loop and invoke the API Gateway endpoint successfully
for i in $(seq 1 $NUM_INVOCATIONS); do
    echo "Invoking API Gateway endpoint (attempt $i/$NUM_INVOCATIONS)"
    curl -X POST "$API_GATEWAY_ENDPOINT"
    echo ""
    sleep 5
done

