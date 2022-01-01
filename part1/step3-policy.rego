package myapi.policy

default allow = false

allow {
  n_as_string := format_int(input.n, 10)
  url := concat("", ["http://localhost:8282/is_odd?n=", n_as_string])
  response := http.send({"method": "GET", "url": url})
  response.body.allow  # `allow` is a boolean flag in the JSON output of the server.
}
