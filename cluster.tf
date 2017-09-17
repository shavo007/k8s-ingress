provider "aws" {
  region  = "ap-southeast-2"
}

resource "aws_s3_bucket" "shane-s3-bucket" {
  bucket = "${var.shane_env_name}-bucket"
  region = "${var.shane_bucket_region}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "Kops"
    Environment = "${var.shane_env_name}"
  }
}
