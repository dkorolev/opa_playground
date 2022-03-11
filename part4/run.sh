#!/bin/bash

OPA_BINARY=${1:-opa}
OPA_SERVER=${2:-http://localhost:8181}

INPUT=input.txt
GOLDEN=golden.txt
TMPFILE=$(mktemp)

$OPA_BINARY run --server -l error &
OPA_PID=$!
echo "OPA server started, PID $OPA_PID."

sleep 1
 
curl -s -X PUT $OPA_SERVER/v1/policies/myapi --data-binary @policy.rego >/dev/null || (echo "Faied to upload the policy."; exit 1)

echo -n >$TMPFILE
while IFS= read -r TESTCASE ; do
  curl -s -X POST $OPA_SERVER/v1/data/myapi/allow --data-binary '{"input":'$TESTCASE'}' | jq .result >>$TMPFILE
done < "$INPUT"

# TODO(dkorolev): Is there a cleaner way to stop the OPA server?
echo "Shutting down the OPA server."
kill $OPA_PID
wait

if [ -f "$GOLDEN" ] ; then
  diff "$GOLDEN" "$TMPFILE" && (echo "PASS"; rm "$TMPFILE"; exit 0) || (echo "FAIL, see '$TMPFILE'"; exit 1)
else
  (mv "$TMPFILE" "$GOLDEN"; echo 'Created `'"$GOLDEN"'`.')
fi
