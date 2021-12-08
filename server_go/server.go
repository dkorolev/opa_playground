package main

import (
  "fmt"
  "net/http"
  "strconv"
  "encoding/json"
  "os"
)

type Response struct {
  Allow bool `json:"allow"`
}

func HandlerACL(w http.ResponseWriter, req *http.Request) {
  response := Response{false}
  n_as_string := req.URL.Query().Get("n")
  n, err := strconv.Atoi(n_as_string)
  if err == nil {
    response.Allow = (n % 2) != 0
  }
  w.Header().Set("Content-Type", "application/json")
  json.NewEncoder(w).Encode(response)
}

func HandlerKill(w http.ResponseWriter, req *http.Request) {
  os.Exit(0)
}

func main() {
  http.HandleFunc("/", HandlerACL)
  http.HandleFunc("/kill", HandlerKill)
  fmt.Println("Go server listening on localhost:8282")
  http.ListenAndServe(":8282", nil)
}
