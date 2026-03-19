# -----------------------------------------------------------------------------
# GCP Security Module
# Cloud Armor security policy with OWASP rules, SCC notification config,
# and service accounts with least privilege.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ─── Cloud Armor Security Policy ─────────────────────────────
resource "google_compute_security_policy" "this" {
  name        = "${local.name_prefix}-armor-policy"
  project     = var.gcp_project_id
  description = "Cloud Armor policy for ${local.name_prefix} with OWASP rules"

  # Default rule - allow
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }

  # Block XSS attacks
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }
    description = "Block Cross-Site Scripting (XSS) attacks"
  }

  # Block SQL Injection
  rule {
    action   = "deny(403)"
    priority = "1001"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }
    description = "Block SQL Injection (SQLi) attacks"
  }

  # Block Local File Inclusion
  rule {
    action   = "deny(403)"
    priority = "1002"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
      }
    }
    description = "Block Local File Inclusion (LFI) attacks"
  }

  # Block Remote File Inclusion
  rule {
    action   = "deny(403)"
    priority = "1003"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rfi-v33-stable')"
      }
    }
    description = "Block Remote File Inclusion (RFI) attacks"
  }

  # Block Remote Code Execution
  rule {
    action   = "deny(403)"
    priority = "1004"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-v33-stable')"
      }
    }
    description = "Block Remote Code Execution (RCE) attacks"
  }

  # Block Protocol Attacks
  rule {
    action   = "deny(403)"
    priority = "1005"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('protocolattack-v33-stable')"
      }
    }
    description = "Block protocol attacks"
  }

  # Rate limiting
  rule {
    action   = "throttle"
    priority = "2000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Rate limiting - 1000 requests per minute per IP"
    rate_limit_options {
      rate_limit_threshold {
        count        = 1000
        interval_sec = 60
      }
      conform_action = "allow"
      exceed_action  = "deny(429)"
    }
  }
}

# ─── SCC Notification Config ─────────────────────────────────
resource "google_pubsub_topic" "scc_findings" {
  name    = "${local.name_prefix}-scc-findings"
  project = var.gcp_project_id

  labels = {
    project     = var.project
    environment = var.environment
  }
}

# ─── Workload Identity Service Account ───────────────────────
resource "google_service_account" "workload" {
  account_id   = "${local.name_prefix}-workload"
  display_name = "GKE Workload Identity SA - ${var.environment}"
  project      = var.gcp_project_id
}

# Grant minimal permissions to workload SA
resource "google_project_iam_member" "workload_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workload.email}"
}

resource "google_project_iam_member" "workload_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.workload.email}"
}

resource "google_project_iam_member" "workload_trace_agent" {
  project = var.gcp_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.workload.email}"
}
