# -----------------------------------------------------------------------------
# GCP Networking Module
# VPC, subnets with secondary ranges for pods/services, Cloud NAT,
# Cloud Router, and firewall rules.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
  subnet_cidr = cidrsubnet(var.vpc_cidr, 4, 0)
  pods_cidr   = "10.${var.environment == "dev" ? 64 : var.environment == "stg" ? 80 : 96}.0.0/14"
  svc_cidr    = "10.${var.environment == "dev" ? 68 : var.environment == "stg" ? 84 : 100}.0.0/20"
}

# ─── VPC Network ─────────────────────────────────────────────
resource "google_compute_network" "this" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ─── GKE Subnet with Secondary Ranges ────────────────────────
resource "google_compute_subnetwork" "gke" {
  name                     = "${local.name_prefix}-gke-subnet"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = local.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = local.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = local.svc_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ─── Cloud Router ────────────────────────────────────────────
resource "google_compute_router" "this" {
  name    = "${local.name_prefix}-router"
  region  = var.region
  network = google_compute_network.this.id
}

# ─── Cloud NAT ───────────────────────────────────────────────
resource "google_compute_router_nat" "this" {
  name                               = "${local.name_prefix}-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ─── Firewall Rules ──────────────────────────────────────────

# Allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name_prefix}-allow-internal"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [local.subnet_cidr, local.pods_cidr, local.svc_cidr]
  priority      = 1000
}

# Allow GCP health check probes
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.name_prefix}-allow-health-checks"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  priority      = 1000
}

# Allow GKE master to communicate with nodes
resource "google_compute_firewall" "allow_master_to_nodes" {
  name    = "${local.name_prefix}-allow-master"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  source_ranges = ["172.16.0.0/28"]
  target_tags   = ["gke-node"]
  priority      = 1000
}

# Deny all ingress by default
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${local.name_prefix}-deny-all-ingress"
  network = google_compute_network.this.name

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 65534
}
