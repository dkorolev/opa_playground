#!/bin/bash
#
# Example run: `./step1.sh ~/Downloads/opa`.
OPA_BINARY=${1:-./opa}
OPA_SERVER=${2:-http://localhost:8181}

$OPA_BINARY run --server &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
echo
echo "Uploading the ACLs and the policy."
curl -i -s -X PUT $OPA_SERVER/v1/data/myapi/acl --data-binary @step1-acl.json
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @step1-policy.rego | jq .

echo
echo "Running the test queries."
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "user": "alice", "access": "write" } }' | jq
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "user": "bob", "access": "write" } }' | jq .
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "user": "bob", "access": "read" } }' | jq .
curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/whocan --data-binary '{ "input": { "access": "read" } }' | jq .

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo
echo "Shutting down the OPA server."
kill $OPA_PID
wait
