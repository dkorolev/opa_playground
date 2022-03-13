#!/bin/bash
#
# A simple script to start an OPA server with a trivial policy for a performance test.

OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA background PID: $OPA_PID"

sleep 1
 
if ! curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @policy.rego >/dev/null ; then
  echo "Failed to upload policy into OPA."
  kill $OPA_PID
  kill -9 $OPA_PID
  wait
  exit 1
else
  echo "OPA policy uploaded successfully."
fi

echo 'OPA server up and running on `localhost:8181`, ready for the test, Ctrl+C to stop.'
echo
echo 'Try:'
echo "curl -s -X POST $OPA_SERVER/v1/data/myapi/answer" '--data-binary '"'"'{"input":{}}'"'"' | jq .result'
echo "curl -s -X POST $OPA_SERVER/v1/data/myapi/sum   " '--data-binary '"'"'{"input":{"a":1,"b":2}}'"'"' | jq .result'
echo "curl -s -X POST $OPA_SERVER/v1/data/myapi/allow " '--data-binary '"'"'{"input":{"a":3,"b":4,"c":6}}'"'"' | jq .result'
echo "curl -s -X POST $OPA_SERVER/v1/data/myapi/allow " '--data-binary '"'"'{"input":{"a":3,"b":4,"c":8}}'"'"' | jq .result'

wait
