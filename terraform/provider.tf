terraform {
  backend "s3" {
    bucket       = "pag-aws-infra-state"
    key          = "projects/AWS-INFRA/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true #s3 native locking
    skip_bucket_creation = true
  }
}


