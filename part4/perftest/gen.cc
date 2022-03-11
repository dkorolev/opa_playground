#include "../../deps/current/bricks/dflags/dflags.h"
#include "../../deps/current/bricks/util/random.h"
#include "../../deps/current/bricks/file/file.h"
#include "../../deps/current/typesystem/serialization/json.h"

DEFINE_uint64(n, 10u, "How many requests to generate.");
DEFINE_uint16(k, 5u, "How many letters to use, to generate `k!` input strings.");
DEFINE_double(fraction_pass, 0.35, "What fraction of bitsets to use for `pass`.");
DEFINE_double(fraction_fail, 0.15, "What fraction of bitsets to use for `fail`.");

CURRENT_STRUCT(Request) {
  CURRENT_FIELD(role, std::string);
  CURRENT_FIELD(pass_roles, std::vector<std::string>);
  CURRENT_FIELD(fail_roles, std::vector<std::string>);
};

int main(int argc, char** argv) {
  ParseDFlags(&argc, &argv);

  if (!(FLAGS_k >= 2 && FLAGS_k <= 10)) {
    std::cerr << "You really want a small '--k`." << std::endl;
    std::exit(-1);
  }

  std::string s(FLAGS_k, '.');
  for (uint32_t i = 0u; i < FLAGS_k; ++i) {
    s[i] = 'A' + i;
  }

  std::vector<std::string> roles;
  do {
    roles.push_back(s);
  } while (std::next_permutation(std::begin(s), std::end(s)));

  std::random_device rd;
  std::mt19937 g(rd());
  std::uniform_int_distribution<size_t> rng(0u, roles.size() - 1u);

  size_t n1 = static_cast<size_t>(roles.size() * FLAGS_fraction_pass);
  size_t n2 = static_cast<size_t>(roles.size() * FLAGS_fraction_fail);
  for (uint64_t t = 0u; t < FLAGS_n; ++t) {
    std::shuffle(std::begin(roles), std::end(roles), g);
    Request r;
    r.role = roles[rng(rd)];
    for (size_t i = 0u; i < n1; ++i) {
      r.pass_roles.push_back(roles[i]);
    }
    for (size_t i = 0u; i < n2; ++i) {
      r.fail_roles.push_back(roles[roles.size() - 1u - i]);
    }
    std::cout << JSON(r) << std::endl;
  }
}
