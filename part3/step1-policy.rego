package myapi.policy

default d2 = false
default d3 = false
default d5 = false
default d7 = false

default allow = false

allow {
  d2
  d3
  d5
  d7
}

d2 { (input.n % 2) == 0 }
d3 { (input.n % 3) == 0 }
d5 { (input.n % 5) == 0 }
d7 { (input.n % 7) == 0 }
