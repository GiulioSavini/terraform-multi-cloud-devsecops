terraform {
  backend "s3" {
    bucket         = "devsecops-stg-tfstate"
    key            = "stg/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-stg-tflock"
  }
}
