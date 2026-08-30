# Bounded context: access-control

Owns detection and edge protection: WAF and rate limiting, cloud threat
detection, the managed secret store, and the identities workloads assume.

## Invariants

1. **This context creates no networks.** It attaches to the fabric published by
   `domains/networking`.
2. **Production routes its security diagnostics somewhere.** In `prd`, Azure
   without a Log Analytics workspace fails at plan time: diagnostics with no
   destination produce no evidence.
3. **The rate limit is bounded on both sides.** A value high enough to never
   trigger is indistinguishable from having no rate limit at all.

## Two secret stores, deliberately

`secret_store` is the *cloud* secret store (Key Vault). The in-cluster Vault is
a different context — `domains/secrets-management` — with a different threat
model and a different failure domain. They are not interchangeable and the
naming keeps them apart.
