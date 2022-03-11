#!/bin/bash
#
# Example run: `./step1.sh ~/Downloads/opa`.
OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @policy.rego >/dev/null || echo "Faied to upload the policy."

echo -n "Should be 42: "
curl -s -X POST $OPA_SERVER/v1/data/myapi/answer --data-binary '{ "input": {} }' | jq .result
echo -n "Should be 17: "
curl -s -X POST $OPA_SERVER/v1/data/myapi/sum --data-binary '{ "input": { "a": 8, "b": 9}}' | jq .result

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo "Shutting down the OPA server."
kill $OPA_PID
wait
