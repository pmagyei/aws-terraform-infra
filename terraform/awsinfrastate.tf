resource "aws_s3_bucket" "pag-aws-infra-state" {
  bucket = "pag-aws-infra-state"
  tags = {
    managed-by = "terraform"
    owner = "pmagyei"
    project = "aws-infra"
    provider = "terraorm"
    environment = "eu-west-2"
    workload = "ci-cd-automation" 
  }
}
       

resource "aws_s3_bucket_public_access_block" "pag-aws-infra-state-acl" {
  bucket = aws_s3_bucket.pag-aws-infra-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "pag-aws-infra-state-versioning" {
  bucket = aws_s3_bucket.pag-aws-infra-state.id
  versioning_configuration {
    status = "Enabled"
  }

}
