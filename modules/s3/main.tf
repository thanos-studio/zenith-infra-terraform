data "aws_caller_identity" "current" {}

locals {
  # Configure S3 bucket names
  web_static_bucket_name = "${var.prefix}-web-static-${data.aws_caller_identity.current.account_id}"
  app_data_bucket_name   = "${var.prefix}-app-data-${data.aws_caller_identity.current.account_id}"

  # Import the S3 public getobject policy from the policies directory
  s3_public_getobject_policy = templatefile("${path.module}/policies/s3_public_getobject.json", {
    bucket_name = local.web_static_bucket_name
  })
}

### --------------------------------------------------
### Web Static Bucket
### --------------------------------------------------
# Web static bucket for frontend
resource "aws_s3_bucket" "web_static_bucket" {
  bucket = local.web_static_bucket_name
  tags = {
    Name = local.web_static_bucket_name
  }
}

# Enable versioning for the web static bucket (for data integrity and recovery)
resource "aws_s3_bucket_versioning" "web_static_bucket_versioning" {
  bucket = aws_s3_bucket.web_static_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Allow public access to the web static bucket (for frontend access)
resource "aws_s3_bucket_public_access_block" "web_static_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.web_static_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Allow public GetObject access to the web static bucket (for frontend access)
resource "aws_s3_bucket_policy" "web_static_bucket_policy" {
  bucket     = aws_s3_bucket.web_static_bucket.id
  policy     = local.s3_public_getobject_policy
  depends_on = [aws_s3_bucket_public_access_block.web_static_bucket_public_access_block]
}

# Configure the web static bucket website configuration (for frontend access)
resource "aws_s3_bucket_website_configuration" "web_static_bucket_website_configuration" {
  bucket = aws_s3_bucket.web_static_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# Configure the web static bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "web_static_bucket_cors_configuration" {
  bucket = aws_s3_bucket.web_static_bucket.id
  cors_rule {
    allowed_headers = var.web_static_bucket_allowed_headers
    allowed_methods = var.web_static_bucket_allowed_methods
    allowed_origins = var.web_static_bucket_allowed_origins
    expose_headers  = var.web_static_bucket_expose_headers
    max_age_seconds = var.web_static_bucket_max_age_seconds
  }
}

### --------------------------------------------------
### App Data Bucket
### --------------------------------------------------
# App data bucket
resource "aws_s3_bucket" "app_data_bucket" {
  bucket = local.app_data_bucket_name
  tags = {
    Name = local.app_data_bucket_name
  }
}

# Enable versioning for the app data bucket (for data integrity and recovery)
resource "aws_s3_bucket_versioning" "app_data_bucket_versioning" {
  bucket = aws_s3_bucket.app_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to the app data bucket
resource "aws_s3_bucket_public_access_block" "app_data_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.app_data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}