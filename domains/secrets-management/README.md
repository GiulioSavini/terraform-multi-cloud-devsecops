# Bounded context: secrets-management

Owns the in-cluster secret store: Vault in HA mode on Raft storage.

Distinct from the cloud secret store owned by `domains/access-control`.
Different threat model, different failure domain, and deliberately not
interchangeable.

## Invariants

1. **Raft needs an odd replica count.** An even number cannot establish quorum
   reliably.
2. **At least three replicas in production.** With fewer, a single node failure
   loses quorum and seals the vault.
3. **TLS is never disabled in production**, whatever the service mesh provides.

## Initialisation is not automated

Vault is deployed sealed. Initialisation and unseal key distribution are
deliberately manual: automating them would mean this Terraform run holding the
root token and unseal keys, which puts them in state.
