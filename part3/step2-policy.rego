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

# NOTE(dkorolev): Change `http://localhost:8282` into `http://current.ai` to not bother with building the C++ binary.

d2 {
  n_as_string := format_int(input.n, 10)
  url := concat("", ["http://localhost:8282/d2?n=", n_as_string])
  response := http.send({"method": "GET", "url": url})
  response.body.is_divisible
}

d3 {
  n_as_string := format_int(input.n, 10)
  url := concat("", ["http://localhost:8282/d3?n=", n_as_string])
  response := http.send({"method": "GET", "url": url})
  response.body.is_divisible
}

d5 {
  n_as_string := format_int(input.n, 10)
  url := concat("", ["http://localhost:8282/d5?n=", n_as_string])
  response := http.send({"method": "GET", "url": url})
  response.body.is_divisible
}

d7 {
  n_as_string := format_int(input.n, 10)
  url := concat("", ["http://localhost:8282/d7?n=", n_as_string])
  response := http.send({"method": "GET", "url": url})
  response.body.is_divisible
}
