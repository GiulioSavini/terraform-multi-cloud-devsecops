terraform {
  backend "s3" {
    bucket         = "devsecops-tfstate-prd"
    key            = "prd/services-azure.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-tflock-prd"
  }
}
