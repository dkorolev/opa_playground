# opa_playground

Make sure to `git clone --recursive git@github.com:dkorolev/opa_playground.git`.

## Part 1: External Calls

### Step 1: An OPA Server with a simple policy

Following the instructions from [here](https://www.redhat.com/en/blog/open-policy-agent-part-i-%E2%80%94-introduction).

Synopsis: `./step1.sh`, or `./step1.sh <path_to_opa_binary>` if the latter is installed elsewhere.

Expected output:

```
Running the test queries.
true
false
true
[
  "alice",
  "bob"
]
```

### Step 2: Allow for odd `n`-s in the input JSON, deny for even `n`-s.

Synopsis: `./step2.sh`, or `./step2.sh <path_to_opa_binary>` if the latter is installed elsewhere.

Expected output:

```
Running the test queries.
false
true
false
true
false
```

### Step 3: Same as step 2 above, but talking to a Go service behind the scenes.

Synopsis: Same as step 2, and needs `go` installed.

Expected output: same as in step 2 above.

## Part 2: Large Data

### Run

Synopsis: `./run.sh`, or `./run.sh <path_to_opa_binary>` if the latter is installed elsewhere.

Expected/possible result:

```
Uploading the ACLs.

Before ACLs upload, `opa` RAM usage:  total           722552K

ACLS size:                           12K -rw-rw-r-- 1 dima dima 287 Jan  4 17:30 acls.json

real 0m0.012s
user 0m0.005s
sys  0m0.006s

After ACLs upload, `opa` RAM usage:  total           722552K

Making sure the `acls.json` was uploaded correctly.
LOCAL: bc0ba342bded4a2b3c58681d07eb9bde  -
OPA:   bc0ba342bded4a2b3c58681d07eb9bde  -

```

### Regenerate Data

Run `make` (or `NDEBUG=1 make`) to build `./.current/gen`.

Then `.current/gen --help` shows its command-line flags.

To generate some example large input, run `./.current/gen -n 1000000 -m 1000000`, or add more zeroes as needed. Even on this small 50MB input it takes ~6 seconds on my machine for OPA to accept this data, and its memoty footprint increases ~27x the size of `acls.json`.

Don't commit, or even diff, this large `acls.json` if you do re-generate it.

Expected/possible result after regenerating `acls.json`:

```
Uploading the ACLs.

Before ACLs upload, `opa` RAM usage:  total           722808K

ACLS size:                           50M -rw-rw-r-- 1 dima dima 50M Jan  4 17:43 acls.json

real 0m6.264s
user 0m0.004s
sys  0m0.131s

After ACLs upload, `opa` RAM usage:  total          2100516K
```

Uploading 50MB of JSON data took 6 seconds.

The memory footprint went up from 722MB to 2.1GB. This is my experimental confirmation of the ~25x .. ~30x coefficient (it's 27.5x in this example).

For the record, a few minutes were not enough to retrieve the JSON back from OPA for comparison. Looks like the OPA engine is re-assembling it from bits and pieces, which is a slow process by itself. I've confirmed the returned JSON is correct on smaller examples though.

## Part 3: Parallel Execution

### Step 1: A simple regression test

Only the inputs divisible by 210 (which is `2*3*5*7`) resut in `true`:

```
Running the test queries.
N=201: false
N=202: false
N=203: false
N=204: false
N=205: false
N=206: false
N=207: false
N=208: false
N=209: false
N=210: true
N=211: false
N=212: false
N=213: false
N=214: false
N=215: false
N=216: false
N=217: false
N=218: false
N=219: false
N=220: false
```

### Step 2: The same logic where the check is an external call

Possible result:

```
Running the test queries.
N=209: false
N=210: true
N=211: false

Now the timing tests.


N=210: true

real 0m8.034s
user 0m0.076s
sys  0m0.008s


N=211: false

real 0m2.016s
user 0m0.038s
sys  0m0.014s


N=212: false

real 0m4.019s
user 0m0.036s
sys  0m0.015s


N=216: false

real 0m6.022s
user 0m0.044s
sys  0m0.010s


N=240: false

real 0m8.023s
user 0m0.040s
sys  0m0.011s
```

While the server is running you can confirm that some `curl localhost:8282/d5?n=3` takes a tad over two seconds.

Evidently, the time it takes to evaluate the policy is not two seconds, which would be the case if OPA ran all the requests in parallel, but two * `N` seconds, where `N` is the number of sequential calls OPA makes.
