#include "../deps/current/bricks/dflags/dflags.h"
#include "../deps/current/bricks/util/random.h"
#include "../deps/current/bricks/file/file.h"
#include "../deps/current/typesystem/serialization/json.h"

// To generate a large ACLs list: `--n 1000000`, `--m 1000000`.
// Run with `--help` for details.
DEFINE_uint64(n, 5u, "How many users to generate.");
DEFINE_uint64(m, 5u, "How many resources to generate.");
DEFINE_uint64(z, 10u, "How many requests to generate.");
DEFINE_uint16(k, 26u, "How many letters to use as `bits` for identities and resources");
DEFINE_uint16(q, 3u, "How many `bits` to set per user/resource.");
DEFINE_string(file_acls, "acls.json", "The output file name for ACL lists.");
DEFINE_string(file_requests, "requests.sh", "The output file name for ACL lists.");

inline void RecursivelyFillBitsets( std::vector<std::vector<std::string>>& B, std::vector<std::string>& v, uint16_t i = 0u) {
  if (v.size() == FLAGS_q) {
    B.push_back(v);
  } else if (i < FLAGS_k) {
    v.push_back(".");
    for (uint16_t j = i; j < FLAGS_k; ++j) {
      v.back()[0u] = 'A' + j;
      RecursivelyFillBitsets(B, v, j + 1u);
    }
    v.pop_back();
  }
}

CURRENT_STRUCT(ACLs) {
  CURRENT_FIELD(identity, (std::map<std::string, std::vector<std::string>>));
  CURRENT_FIELD(resource, (std::map<std::string, std::vector<std::string>>));
};
CURRENT_STRUCT(REQInput) {
  CURRENT_FIELD(identity, std::string);
  CURRENT_FIELD(resource, std::string);
};
CURRENT_STRUCT(REQ) {
  CURRENT_FIELD(input, REQInput);
};

int main(int argc, char** argv) {
  ParseDFlags(&argc, &argv);

  std::vector<std::vector<std::string>> B;
  {
    std::vector<std::string> v;
    RecursivelyFillBitsets(B, v);
  }
  std::cerr << "Bitsets: " << B.size() << ", should be C(" << FLAGS_k << ", " << FLAGS_q << ")." << std::endl;

  std::vector<std::string> U;
  std::vector<std::string> R;

  for (uint64_t u = 0u; u < FLAGS_n; ++u) {
    U.push_back(current::strings::Printf("U%08d", int(u + 1u)));
  }
  for (uint64_t r = 0u; r < FLAGS_m; ++r) {
    R.push_back(current::strings::Printf("R%08d", int(r + 1u)));
  }

  ACLs acls;
  for (uint64_t u = 0u; u < FLAGS_n; ++u) {
    acls.identity[U[u]] = B[current::random::RandomUInt64(0u, B.size() - 1u)];
  }
  for (uint64_t r = 0u; r < FLAGS_m; ++r) {
    acls.resource[R[r]] = B[current::random::RandomUInt64(0u, B.size() - 1u)];
  }
  current::FileSystem::WriteStringToFile(JSON(acls), FLAGS_file_acls.c_str());

  std::ofstream fo(FLAGS_file_requests);
  REQ r;
  for (uint64_t z = 0u; z < FLAGS_z; ++z) {
    r.input.identity = U[current::random::RandomUInt64(0u, U.size() - 1u)];
    r.input.resource = R[current::random::RandomUInt64(0u, R.size() - 1u)];
    fo << "curl -s -X POST $OPA_SERVER/v1/data/myapi/policy/allow --data-binary '" << JSON(r) << "' | jq .result\n";
  }
}
