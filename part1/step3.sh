#!/bin/bash
#
# Example run: `./step3.sh ~/Downloads/opa`.
OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}
GO_SOURCE=${3-./server_go/server.go}

go run $GO_SOURCE &
echo "Go server started."

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
echo
echo "Uploading the policy."
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @step3-policy.rego | jq .

echo
echo "Running the test queries."
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 0 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 1 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 2 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 3 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 42 } }' | jq .result

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo
echo "Shutting down the OPA server."
kill $OPA_PID

# TODO(dkorolev): Is there a cleaner way to stop a Go server?
echo "Shutting down the Go server."
curl -s localhost:8282/kill 2>&1 >/dev/null

wait
