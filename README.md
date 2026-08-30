# terraform-multi-cloud-devsecops

A DevSecOps Kubernetes platform across EKS, AKS and GKE, organised as **bounded
contexts** rather than as a pile of provider modules.

[![CI](https://github.com/GiulioSavini/terraform-multi-cloud-devsecops/actions/workflows/ci.yml/badge.svg)](https://github.com/GiulioSavini/terraform-multi-cloud-devsecops/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Why it is laid out this way

The tree used to be `modules/aws/eks`, `modules/azure/aks`, `modules/gcp/gke` —
organised by vendor, which makes the cloud the primary axis and the problem
being solved a secondary one. Here the **domain is the axis** and the provider
is an implementation detail private to the context.

```
domains/<context>/
    contract.tf      the public interface and its invariants
    outputs.tf       what the context publishes, same shape for every cloud
    README.md        the invariants, written down
    aws/ azure/ gcp/ adapters, private to the context
```

`scripts/check-boundaries.sh` fails CI if a context is consumed through one of
its adapters instead of its contract.

### The contexts

| Context | Owns | Adapters |
|---|---|---|
| [`networking`](domains/networking) | Address space, subnets, egress | aws, azure, gcp |
| [`access-control`](domains/access-control) | WAF, threat detection, cloud secret store | aws, azure, gcp |
| [`cluster-platform`](domains/cluster-platform) | Managed control planes and node pools | aws, azure, gcp |
| [`traffic-ingress`](domains/traffic-ingress) | Ingress, certificates, external DNS | aws, azure, gcp |
| [`policy-enforcement`](domains/policy-enforcement) | Gatekeeper admission control | kubernetes |
| [`secrets-management`](domains/secrets-management) | Vault HA on Raft | kubernetes |
| [`observability`](domains/observability) | Prometheus and Grafana | kubernetes |
| [`service-mesh`](domains/service-mesh) | Linkerd and pod-to-pod mTLS | kubernetes |

`cluster-platform` is the seam. Below it is cloud infrastructure; above it,
everything runs inside a cluster and consumes `clusters` without knowing whether
it is EKS, AKS or GKE.

The last four contexts have a single `kubernetes/` adapter because their
implementation is Kubernetes rather than a cloud.

## Two-phase apply, on purpose

The `kubernetes` and `helm` providers cannot be configured against a cluster
that does not exist yet. Configuring them from a module output in the same root
is a common arrangement and it fails on a clean apply — the previous version of
this repository did exactly that.

So there are two applications and two roots per cluster:

```
applications/cloud-foundation    networking + access-control + cluster-platform
applications/cluster-services    ingress + gatekeeper + vault + monitoring + mesh

deployments/<env>/foundation     apply first
deployments/<env>/services-<cloud>   reads the foundation's state at plan time,
                                     which is what makes the providers configurable
```

One services root per cluster: the `kubernetes` provider addresses exactly one
API server, and fanning one root across three clusters would mean threading
provider aliases through every module.

```bash
cd deployments/prd/foundation && terraform apply
cd ../services-aws            && terraform apply
```

Cluster credentials are fetched per cloud in the way that keeps long-lived
secrets out of state: `aws eks get-token` for EKS, the `azurerm_kubernetes_cluster`
data source for AKS, and a short-lived `google_client_config` token for GKE.

## Compliance

Controls are declared in [`compliance/controls`](compliance/controls), mapped to
**CIS Benchmarks (including CIS Kubernetes), ISO 27001 Annex A, SOC 2 TSC and
NIS2**. Each names the context that implements it and the contract output that
evidences it.

Enforcement happens in three places, because none of them sees what the others
see:

| Where | What it catches |
|---|---|
| Context preconditions | A configuration that would apply cleanly and not work: a public API server in prd, an even Raft replica count, TLS disabled on Vault, an unpinned Kubernetes version |
| [`compliance/policies`](compliance/policies) (conftest, plan time) | What Terraform is about to create: missing tags, unencrypted buckets, public ingress that does not declare itself, EKS without audit logging |
| [`policy-enforcement`](domains/policy-enforcement) (Gatekeeper, admission time) | What anyone applies to the cluster afterwards |

The rego policies have their own unit tests — 29 of them, covering the
violating and the compliant case for every rule. `make policy` runs them.

## What this repository is not

It is a **reference platform**, not a product. It has never been applied against
a billing account by its author — every check in CI is static: format, validate,
lint, policy unit tests, misconfiguration scanning. Nothing here has been proven
against live cloud APIs, and applying it will cost a significant amount of
money.

Vault is deployed sealed; initialisation and unseal key distribution are
deliberately manual, because automating them would put the root token and unseal
keys in Terraform state.

## License

MIT — see [LICENSE](LICENSE).
