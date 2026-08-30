---
name: Bug Report
about: Report a bug to help us improve
title: "[BUG] "
labels: bug
assignees: GiulioSavini
---

## Bug Description

A clear and concise description of the bug.

## Module

Which module is affected?

- [ ] `domains/networking`
- [ ] `domains/access-control`
- [ ] `domains/cluster-platform`
- [ ] `domains/traffic-ingress`
- [ ] `domains/policy-enforcement`
- [ ] `domains/secrets-management`
- [ ] `domains/observability`
- [ ] `domains/service-mesh`
- [ ] `platform` (naming, tagging)
- [ ] `compliance` (controls, policies)
- [ ] `applications` (cloud-foundation, cluster-services)
- [ ] `deployments`
- [ ] Other (please specify)

## Environment

- **Cloud Provider**: (AWS / Azure / GCP)
- **Region**:
- **OS**:
- **Terraform Version**:
- **Module Version**:
- **Provider Version(s)**:

## Terraform Version

```
$ terraform version
```

Paste the output of `terraform version` here.

## Expected Behavior

A clear and concise description of what you expected to happen.

## Actual Behavior

A clear and concise description of what actually happened. Include any error messages or logs.

## Steps to Reproduce

1. Configure the module with the following inputs:
   ```hcl
   module "example" {
     source = "..."
     # relevant configuration
   }
   ```
2. Run `terraform init`
3. Run `terraform plan` or `terraform apply`
4. Observe the error

## Terraform Plan/Apply Output

```
Paste relevant terraform output here
```

## Additional Context

Add any other context, screenshots, or configuration files that might help diagnose the issue.
