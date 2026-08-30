terraform {
  backend "s3" {
    bucket         = "devsecops-tfstate-stg"
    key            = "stg/services-azure.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-tflock-stg"
  }
}
