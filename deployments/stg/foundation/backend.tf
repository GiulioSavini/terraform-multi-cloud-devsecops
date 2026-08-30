terraform {
  backend "s3" {
    bucket         = "devsecops-tfstate-stg"
    key            = "stg/foundation.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-tflock-stg"
  }
}
