#!/bin/bash
#
# Example run: `./step1.sh ~/Downloads/opa`.
OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
echo
echo "Uploading the policy."
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @step1-policy.rego | jq .

echo
echo "Running the test queries."
for i in $(seq 201 220) ; do
  echo -n "N=$i: "
  curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$i' } }' | jq .result
done

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo
echo "Shutting down the OPA server."
kill $OPA_PID
wait
