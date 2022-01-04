#!/bin/bash
#
# Example run: `./step2.sh ~/Downloads/opa`.
OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
echo
echo "Uploading the policy."
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @step2-policy.rego | jq .

echo
echo "Running the test queries."
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 0 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 1 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 2 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 3 } }' | jq .result
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": 42 } }' | jq .result

#curl -s -X POST "$OPA_SERVER/v1/data/myapi/policy/allow?explain=full" --data-binary '{ "input": { "n": 42 } }' | jq .
#curl -s -X POST "$OPA_SERVER/v1/data/myapi/policy?explain=full" --data-binary '{ "input": { "n": 1 } }' | jq .

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo
echo "Shutting down the OPA server."
kill $OPA_PID
wait
