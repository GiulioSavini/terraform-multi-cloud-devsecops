terraform {
  backend "s3" {
    bucket         = "devsecops-tfstate-dev"
    key            = "dev/foundation.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "devsecops-tflock-dev"
  }
}
