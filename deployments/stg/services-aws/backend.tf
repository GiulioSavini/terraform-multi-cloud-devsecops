terraform {
  backend "s3" {
    bucket         = "devsecops-tfstate-stg"
    key            = "stg/services-aws.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-tflock-stg"
  }
}
