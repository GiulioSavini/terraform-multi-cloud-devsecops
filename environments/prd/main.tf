# =============================================================================
# Main Configuration - Production Environment
# Locals and core resource definitions
# =============================================================================

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Platform    = "devsecops-multi-cloud"
  }
}
