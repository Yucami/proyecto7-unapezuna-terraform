resource "aws_s3_bucket" "frontend" {
  bucket = "unapezuna-frontend"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "fotos" {
  bucket = "unapezuna-fotos"
}

resource "aws_s3_bucket_public_access_block" "fotos" {
  bucket                  = aws_s3_bucket.fotos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "fotos" {
  bucket = aws_s3_bucket.fotos.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["http://localhost:5173", "https://unapezuna.es"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
