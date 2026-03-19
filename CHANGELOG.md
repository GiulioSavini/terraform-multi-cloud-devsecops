# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- AWS EKS module with managed node groups, OIDC provider, and EKS addons
- AWS networking module with VPC, public/private subnets, NAT gateways, and VPC endpoints
- AWS security module with WAFv2, GuardDuty, AWS Config, and SecurityHub integration
- AWS ingress module with ALB Ingress Controller, cert-manager, and external-dns
- Azure AKS module with node pools, Azure AD RBAC integration, and Key Vault CSI driver
- Azure networking module with VNet, Azure Firewall, and route tables
- Azure security module with Defender for Cloud, Azure Policy, and Key Vault
- Azure ingress module with NGINX Ingress Controller, cert-manager, and external-dns
- GCP GKE module with private clusters, Workload Identity, and Binary Authorization
- GCP networking module with VPC, subnets, and Cloud NAT
- GCP security module with Cloud Armor, Security Command Center, and service accounts
- GCP ingress module with NGINX Ingress Controller, cert-manager, and external-dns
- Shared Vault module with HA deployment using Raft storage backend
- Shared OPA Gatekeeper module with constraint templates and policies
- Shared monitoring module with kube-prometheus-stack (Prometheus, Grafana, Alertmanager)
- Shared service mesh module with Linkerd
- Pre-commit hooks for terraform fmt, validate, tflint, tfsec, and checkov
- GitHub Actions CI/CD pipelines for validation, security scanning, and deployment
- Comprehensive documentation with usage examples for all modules
- TFLint configuration with AWS, Azure, and GCP plugins
- CODEOWNERS for automated review assignment
- Issue templates for bug reports and feature requests
- Pull request template with checklist
- Security policy with vulnerability reporting guidelines
- Contributing guide with branch naming and commit conventions
