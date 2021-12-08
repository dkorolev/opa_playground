package myapi.policy

default allow = false

allow {
  (input.n % 2) != 0
}
