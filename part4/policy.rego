package myapi

setcontains(xs, x) { xs[_] = x }

default pass = false
pass { setcontains(input.pass_roles, input.role) }

default fail = false
fail { setcontains(input.fail_roles, input.role) }

default allow = false
allow {
  pass
  not fail
}
