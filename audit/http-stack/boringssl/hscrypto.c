/* hscrypto.c -- the census's crypto airlock, C half
 * (HTTP-STACK-INTEGRATION-CENSUS.md, "BoringSSL provider", consumer A).
 *
 * General-purpose cryptography for Botlish, straight from the one
 * BoringSSL provider (libcrypto.a; no HTTP, no TLS, no Rust). Its surface
 * is the authority the Botlish module (crypto.bot) grants through its
 * context: hashing, keyed MACs and signatures with keys that never leave
 * this file -- a key is a slot number; its bytes are never copied out and
 * are wiped on release.
 *
 * Every function takes C scalars and byte buffers the Botlish caller
 * exposes for one call (C-POINTER-BORROWING.md): `read noescape` inputs,
 * `write noescape` outputs. Nothing is retained.
 *
 * The provider-identity functions return the addresses this airlock's
 * references resolved to (SHA256, EVP_sha256()'s method table). The Rust
 * unit returns the same addresses as it sees them (hs_bssl_*): in one
 * linking unit with one provider they are equal; with a second copy hidden
 * inside the Rust unit they are not (the census's negative control). */
#include <openssl/base.h>
#include <openssl/curve25519.h>
#include <openssl/digest.h>
#include <openssl/hmac.h>
#include <openssl/mem.h>
#include <openssl/rand.h>
#include <openssl/sha2.h>
#include <stdint.h>
#include <string.h>

#define HSC_KEYS 16

static struct {
    int live;
    uint8_t priv[64];
    uint8_t pub[32];
} keys[HSC_KEYS];

long long hsc_api_version(void) {
    return BORINGSSL_API_VERSION;
}

long long hsc_sha256(const uint8_t *data, unsigned long len, uint8_t *out, unsigned long cap) {
    if (cap < SHA256_DIGEST_LENGTH) {
        return -1;
    }
    SHA256(data, len, out);
    return SHA256_DIGEST_LENGTH;
}

/* HMAC-SHA256 with KEY (the caller's bytes: a MAC key is data here, not a
 * slot; the signature keys below are the airlock's own). */
long long hsc_hmac_sha256(const uint8_t *key, unsigned long klen, const uint8_t *data, unsigned long len, uint8_t *out, unsigned long cap) {
    unsigned int n = 0;
    if (cap < SHA256_DIGEST_LENGTH) {
        return -1;
    }
    if (HMAC(EVP_sha256(), key, klen, data, len, out, &n) == NULL) {
        return -2;
    }
    return (long long)n;
}

/* A new Ed25519 key in a slot: its slot number, or -1 (full). */
long long hsc_ed25519_new(void) {
    for (int i = 0; i < HSC_KEYS; i++) {
        if (!keys[i].live) {
            ED25519_keypair(keys[i].pub, keys[i].priv);
            keys[i].live = 1;
            return i;
        }
    }
    return -1;
}

/* The public key of SLOT (32 bytes): public material may leave. */
long long hsc_ed25519_public(long long slot, uint8_t *out, unsigned long cap) {
    if (slot < 0 || slot >= HSC_KEYS || !keys[slot].live || cap < 32) {
        return -1;
    }
    memcpy(out, keys[slot].pub, 32);
    return 32;
}

long long hsc_ed25519_sign(long long slot, const uint8_t *msg, unsigned long len, uint8_t *sig, unsigned long cap) {
    if (slot < 0 || slot >= HSC_KEYS || !keys[slot].live || cap < 64) {
        return -1;
    }
    return ED25519_sign(sig, msg, len, keys[slot].priv) ? 64 : -2;
}

long long hsc_ed25519_verify(const uint8_t *pub, unsigned long publen, const uint8_t *msg, unsigned long len, const uint8_t *sig, unsigned long siglen) {
    if (publen != 32 || siglen != 64) {
        return -1;
    }
    return ED25519_verify(msg, len, sig, pub);
}

/* Release SLOT: its key material is wiped. */
long long hsc_release(long long slot) {
    if (slot < 0 || slot >= HSC_KEYS || !keys[slot].live) {
        return -1;
    }
    OPENSSL_cleanse(keys[slot].priv, sizeof keys[slot].priv);
    keys[slot].live = 0;
    return 0;
}

/* Provider identity, as this airlock's references resolved. */
long long hsc_provider_sha256_fn(void) {
    return (long long)(intptr_t)&SHA256;
}

long long hsc_provider_evp_sha256(void) {
    return (long long)(intptr_t)EVP_sha256();
}
