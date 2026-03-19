terraform {
  backend "s3" {
    bucket         = "devsecops-dev-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-dev-tflock"
  }
}
