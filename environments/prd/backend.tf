terraform {
  backend "s3" {
    bucket         = "devsecops-prd-tfstate"
    key            = "prd/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-prd-tflock"
  }
}
