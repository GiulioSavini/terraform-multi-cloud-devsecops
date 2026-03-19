# GCP Security Module

Provisions Google Cloud security services including Cloud Armor for web application and DDoS protection, Security Command Center (SCC) for centralized security monitoring, and least-privilege service accounts for workload authentication.

## Usage

```hcl
module "security" {
  source = "./modules/gcp/security"

  project_id  = "my-gcp-project"
  environment = "production"

  # Cloud Armor
  enable_cloud_armor = true
  cloud_armor_policies = {
    default = {
      description = "Default security policy"
      rules = [
        {
          action      = "deny(403)"
          priority    = 1000
          description = "Deny SQL injection"
          expression  = "evaluatePreconfiguredExpr('sqli-stable')"
        },
        {
          action      = "deny(403)"
          priority    = 1001
          description = "Deny XSS attacks"
          expression  = "evaluatePreconfiguredExpr('xss-stable')"
        },
        {
          action      = "throttle"
          priority    = 2000
          description = "Rate limiting"
          expression  = "true"
          rate_limit_options = {
            rate_limit_threshold = {
              count        = 100
              interval_sec = 60
            }
            conform_action = "allow"
            exceed_action  = "deny(429)"
          }
        },
        {
          action      = "allow"
          priority    = 2147483647
          description = "Default allow rule"
          expression  = "true"
        }
      ]
    }
  }

  # Security Command Center
  enable_scc                = true
  scc_notification_configs = {
    critical_findings = {
      description = "Notify on critical findings"
      pubsub_topic = "projects/my-gcp-project/topics/scc-critical"
      filter       = "severity=\"CRITICAL\" OR severity=\"HIGH\""
    }
  }

  # Service Accounts
  service_accounts = {
    gke_nodes = {
      account_id   = "gke-node-sa"
      display_name = "GKE Node Service Account"
      roles = [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/artifactregistry.reader"
      ]
    }
    app_workload = {
      account_id   = "app-workload-sa"
      display_name = "Application Workload Service Account"
      roles = [
        "roles/cloudsql.client",
        "roles/storage.objectViewer"
      ]
    }
  }

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
| `project_id` | GCP project ID | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `enable_cloud_armor` | Enable Cloud Armor security policies | `bool` | `true` | no |
| `cloud_armor_policies` | Map of Cloud Armor policy configurations | `map(object)` | `{}` | no |
| `enable_scc` | Enable Security Command Center | `bool` | `true` | no |
| `scc_notification_configs` | Map of SCC notification configurations | `map(object)` | `{}` | no |
| `service_accounts` | Map of service account configurations | `map(object)` | `{}` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cloud_armor_policy_ids` | Map of Cloud Armor policy names to their IDs |
| `cloud_armor_policy_self_links` | Map of Cloud Armor policy names to their self links |
| `scc_notification_config_names` | Map of SCC notification config names |
| `service_account_emails` | Map of service account names to their email addresses |
| `service_account_ids` | Map of service account names to their unique IDs |
