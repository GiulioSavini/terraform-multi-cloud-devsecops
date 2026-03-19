# -----------------------------------------------------------------------------
# Root Terragrunt Configuration
# Multi-Cloud DevSecOps Platform
# -----------------------------------------------------------------------------

locals {
  # Parse the environment from the directory path
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"))
  env      = try(local.env_vars.locals.environment, "dev")
  project  = "devsecops"
  region   = try(local.env_vars.locals.aws_region, "eu-west-1")
}

# Configure remote state
remote_state {
  backend = "s3"
  generate = {
    path      = "backend_generated.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.project}-${local.env}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.project}-${local.env}-tflock"

    s3_bucket_tags = {
      Name        = "${local.project}-${local.env}-tfstate"
      Environment = local.env
      ManagedBy   = "terragrunt"
    }
  }
}

# Generate provider configurations
generate "providers" {
  path      = "providers_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7.0"
    }
  EOF
}

# Common inputs for all modules
inputs = {
  project     = local.project
  environment = local.env

  common_tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "terraform"
    Platform    = "devsecops-multi-cloud"
  }
}

# Retry configuration
retry_max_attempts       = 3
retry_sleep_interval_sec = 5
