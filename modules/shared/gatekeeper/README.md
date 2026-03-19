# Shared OPA Gatekeeper Module

Deploys Open Policy Agent (OPA) Gatekeeper for Kubernetes admission control with a curated set of constraint templates and policies for security, compliance, and operational best practices enforcement.

## Usage

```hcl
module "gatekeeper" {
  source = "./modules/shared/gatekeeper"

  namespace        = "gatekeeper-system"
  create_namespace = true

  helm_chart_version = "3.14.0"

  replicas          = 3
  audit_interval    = 60
  audit_from_cache  = true

  # Resource limits
  resources = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "1000m"
      memory = "512Mi"
    }
  }

  # Constraint Templates
  enable_default_constraint_templates = true

  constraint_templates = {
    allowed_repos = {
      name = "k8sallowedrepos"
      rego = <<-REGO
        package k8sallowedrepos
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not startswith(container.image, input.parameters.repos[_])
          msg := sprintf("container <%v> has an invalid image repo <%v>", [container.name, container.image])
        }
      REGO
    }
  }

  # Policies (Constraints)
  policies = {
    require_labels = {
      template  = "k8srequiredlabels"
      kind      = "Namespace"
      match_kinds = [{
        api_groups = [""]
        kinds      = ["Namespace"]
      }]
      parameters = {
        labels = ["environment", "team", "managed-by"]
      }
      enforcement_action = "deny"
    }
    allowed_repos = {
      template  = "k8sallowedrepos"
      kind      = "Pod"
      match_kinds = [{
        api_groups = [""]
        kinds      = ["Pod"]
      }]
      parameters = {
        repos = [
          "gcr.io/my-project/",
          "docker.io/library/",
          "quay.io/"
        ]
      }
      enforcement_action = "deny"
    }
    block_privileged = {
      template  = "k8spsprivilegedcontainer"
      kind      = "Pod"
      match_kinds = [{
        api_groups = [""]
        kinds      = ["Pod"]
      }]
      parameters   = {}
      enforcement_action = "deny"
    }
    require_resource_limits = {
      template  = "k8srequiredresources"
      kind      = "Pod"
      match_kinds = [{
        api_groups = [""]
        kinds      = ["Pod"]
      }]
      parameters = {
        limits   = ["cpu", "memory"]
        requests = ["cpu", "memory"]
      }
      enforcement_action = "warn"
    }
  }

  # Exemptions
  exempt_namespaces = [
    "kube-system",
    "gatekeeper-system",
    "cert-manager",
    "vault"
  ]

  labels = {
    environment = "production"
    project     = "multi-cloud-platform"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `namespace` | Kubernetes namespace for Gatekeeper | `string` | `"gatekeeper-system"` | no |
| `create_namespace` | Create the namespace if it does not exist | `bool` | `true` | no |
| `helm_chart_version` | Helm chart version for Gatekeeper | `string` | `"3.14.0"` | no |
| `replicas` | Number of Gatekeeper controller replicas | `number` | `3` | no |
| `audit_interval` | Audit interval in seconds | `number` | `60` | no |
| `audit_from_cache` | Enable audit from cache for performance | `bool` | `true` | no |
| `resources` | CPU and memory resource requests and limits | `object` | `{}` | no |
| `enable_default_constraint_templates` | Deploy the default set of constraint templates | `bool` | `true` | no |
| `constraint_templates` | Map of custom constraint template configurations | `map(object)` | `{}` | no |
| `policies` | Map of policy (constraint) configurations | `map(object)` | `{}` | no |
| `exempt_namespaces` | List of namespaces exempt from Gatekeeper policies | `list(string)` | `["kube-system"]` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `gatekeeper_namespace` | The namespace where Gatekeeper is deployed |
| `constraint_template_names` | List of deployed constraint template names |
| `policy_names` | List of deployed policy (constraint) names |
| `gatekeeper_webhook_name` | The name of the Gatekeeper validating webhook |
| `audit_controller_service` | The name of the audit controller service |
