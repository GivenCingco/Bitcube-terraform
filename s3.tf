module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "bitcube-pipeline-artifacts"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

output "bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}