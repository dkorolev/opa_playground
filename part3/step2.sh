#!/bin/bash
#
# Example run: `./step2.sh ~/Downloads/opa`.
OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

(cd server_cpp; NDEBUG=1 make .current/server_cpp)

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

server_cpp/.current/server_cpp &
SERVER_PID=$!
echo "CPP server started, PID $SERVER_PID."

sleep 1
 
echo
echo "Uploading the policy."
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @step2-policy.rego | jq .

echo
echo "Running the test queries."
for i in $(seq 209 211) ; do
  echo -n "N=$i: "
  curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$i' } }' | jq .result
done

echo
echo "Now the timing tests."

N=$((2*3*5*7))
echo -ne "\n\nN=$N: "
time curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$N' } }' | jq .result

N=$((2*3*5*7+1))
echo -ne "\n\nN=$N: "
time curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$N' } }' | jq .result

N=$((2*(3*5*7+1)))
echo -ne "\n\nN=$N: "
time curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$N' } }' | jq .result

N=$((2*3*(5*7+1)))
echo -ne "\n\nN=$N: "
time curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$N' } }' | jq .result

N=$((2*3*5*(7+1)))
echo -ne "\n\nN=$N: "
time curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '{ "input": { "n": '$N' } }' | jq .result

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo
echo "Shutting down."
kill $SERVER_PID
kill $OPA_PID
wait
