# opa_playground

## Part 1: Compact Data

### Step 1: OPA Server

Following the instructions from [here](https://www.redhat.com/en/blog/open-policy-agent-part-i-%E2%80%94-introduction).

Synopsis: `./step1.sh`, or `./step1.sh <path_to_opa_binary>` if the latter is installed elsewhere.

### Step 2: Allow for odd `n`-s in the input JSON, deny for even `n`-s.

Synopsis: `./step2.sh`, or `./step2.sh <path_to_opa_binary>` if the latter is installed elsewhere.

### Step 3: Same as step 2 above, but talking to a Go service behind the scenes.

Synopsis: Same as step 2, and needs `go` installed.

## Part 2: Large Data

### Run

Synopsis: `./run.sh`, or `./run.sh <path_to_opa_binary>` if the latter is installed elsewhere.
