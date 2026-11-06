/* identity.c -- the BoringSSL provider package's identity symbol
 * (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "The provider"): one defined symbol
 * whose name is the provider's tag and commit, a member of
 * libbotlish_boringssl_crypto.a. A native unit compiled against this
 * provider's headers references it (botlish_http's provider.rs), so linking
 * that unit with another provider -- another revision's archives, a system
 * OpenSSL, none -- fails at link time with this name undefined, instead of
 * running against code its headers did not describe (the HTTP shipping
 * census's B2). The build passes -DBOTLISH_BORINGSSL_ID=TAG_COMMIT. */
#ifndef BOTLISH_BORINGSSL_ID
#error "BOTLISH_BORINGSSL_ID must name the provider (tools/http-package.tcl)"
#endif
#define BOTLISH_CAT2(a, b) a##b
#define BOTLISH_CAT(a, b) BOTLISH_CAT2(a, b)
const unsigned char BOTLISH_CAT(botlish_boringssl_, BOTLISH_BORINGSSL_ID) = 1;
