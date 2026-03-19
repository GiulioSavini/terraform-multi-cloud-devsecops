# AWS Networking Module

Provisions a production-ready VPC with public and private subnets across multiple availability zones, NAT gateways for outbound internet access, and VPC endpoints for secure access to AWS services without traversing the public internet.

## Usage

```hcl
module "networking" {
  source = "./modules/aws/networking"

  vpc_name   = "production-vpc"
  vpc_cidr   = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  vpc_endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }
    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    sts = {
      service             = "sts"
      service_type        = "Interface"
      private_dns_enabled = true
    }
  }

  tags = {
    Environment = "production"
    Project     = "multi-cloud-platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_name` | Name of the VPC | `string` | n/a | yes |
| `vpc_cidr` | CIDR block for the VPC | `string` | n/a | yes |
| `azs` | List of availability zones | `list(string)` | n/a | yes |
| `public_subnets` | List of CIDR blocks for public subnets | `list(string)` | `[]` | no |
| `private_subnets` | List of CIDR blocks for private subnets | `list(string)` | `[]` | no |
| `enable_nat_gateway` | Enable NAT gateways for private subnets | `bool` | `true` | no |
| `single_nat_gateway` | Use a single NAT gateway for all private subnets | `bool` | `false` | no |
| `one_nat_gateway_per_az` | Create one NAT gateway per availability zone | `bool` | `true` | no |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| `enable_dns_support` | Enable DNS support in the VPC | `bool` | `true` | no |
| `vpc_endpoints` | Map of VPC endpoint configurations | `map(object)` | `{}` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vpc_cidr_block` | The CIDR block of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_ids` | List of NAT gateway IDs |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |
| `vpc_endpoint_ids` | Map of VPC endpoint names to their IDs |
