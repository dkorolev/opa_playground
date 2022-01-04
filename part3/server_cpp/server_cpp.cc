#include <iostream>

#include "../../deps/current/blocks/http/api.h"
#include "../../deps/current/bricks/dflags/dflags.h"
#include "../../deps/current/typesystem/serialization/json.h"

DEFINE_uint16(port, 8282, "The port to listen on.");
DEFINE_uint64(sleep_ms, 2000, "The delay to sleep for before sending the response.");

CURRENT_STRUCT(IsDivisibleResponse) {
  CURRENT_FIELD(is_divisible, bool, false);
  CURRENT_CONSTRUCTOR(IsDivisibleResponse)(bool is_divisible = false) : is_divisible(is_divisible) {}
};

int main(int argc, char** argv) {
  ParseDFlags(&argc, &argv);
  auto& server = HTTP(current::net::BarePort(FLAGS_port));
  HTTPRoutesScope scope;
  for (size_t i : {2, 3, 5, 7}) {
    scope += server.Register("/d" + current::ToString(i), [i](Request r) {
      std::thread(
          [i](Request r) {
            std::this_thread::sleep_for(std::chrono::milliseconds(static_cast<int64_t>(FLAGS_sleep_ms)));
            r(IsDivisibleResponse((current::FromString<int>(r.url.query.get("n", "0")) % i) == 0));
          },
          std::move(r))
          .detach();
    });
  }
  std::cout << "Our tiny server is listening on http://localhost:" << FLAGS_port << std::endl;
  server.Join();
}
