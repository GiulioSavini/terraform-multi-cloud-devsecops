# -----------------------------------------------------------------------------
# GCP GKE Module
# Private GKE cluster with separate node pools (system + workload),
# Workload Identity, Binary Authorization, VPC-native, shielded nodes.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
  location    = var.regional ? var.region : "${var.region}-b"
}

# ─── GKE Node Service Account ────────────────────────────────
resource "google_service_account" "gke_nodes" {
  account_id   = "${var.cluster_name}-nodes"
  display_name = "GKE Node Service Account - ${var.cluster_name}"
}

resource "google_project_iam_member" "gke_log_writer" {
  project = data.google_project.current.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_metric_writer" {
  project = data.google_project.current.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_monitoring_viewer" {
  project = data.google_project.current.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_artifact_reader" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_resource_metadata_writer" {
  project = data.google_project.current.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# ─── GKE Cluster ─────────────────────────────────────────────
resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = local.location

  min_master_version = var.kubernetes_version

  network    = var.network
  subnetwork = var.subnetwork

  # Remove default node pool, we create our own
  remove_default_node_pool = true
  initial_node_count       = 1

  # Private Cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.environment != "dev"
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # VPC-native (alias IPs)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }

  # Binary Authorization
  binary_authorization {
    evaluation_mode = var.environment == "prd" ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  # Release Channel
  release_channel {
    channel = var.environment == "prd" ? "STABLE" : "REGULAR"
  }

  # Logging
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Monitoring
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Master Auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Network Policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  resource_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }

  deletion_protection = var.environment == "prd"
}

# ─── System Node Pool ────────────────────────────────────────
resource "google_container_node_pool" "system" {
  name     = "system"
  cluster  = google_container_cluster.this.name
  location = local.location

  initial_node_count = var.node_count

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.node_machine_type
    disk_size_gb    = var.node_disk_size_gb
    disk_type       = "pd-balanced"
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      pool        = "system"
      environment = var.environment
    }

    taint {
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    }
  }
}

# ─── Workload Node Pool ──────────────────────────────────────
resource "google_container_node_pool" "workload" {
  name     = "workload"
  cluster  = google_container_cluster.this.name
  location = local.location

  initial_node_count = var.node_count

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.node_machine_type
    disk_size_gb    = var.node_disk_size_gb * 2
    disk_type       = "pd-balanced"
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      pool        = "workload"
      environment = var.environment
    }
  }
}

data "google_project" "current" {}
