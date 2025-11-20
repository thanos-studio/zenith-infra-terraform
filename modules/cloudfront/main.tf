locals {
  s3_origin_id         = var.origin_id != "" ? var.origin_id : "${var.prefix}-s3-origin"
  alb_origin_id        = var.alb_origin_id != "" ? var.alb_origin_id : "${var.prefix}-alb-origin"
  distribution_comment = var.comment != "" ? var.comment : "${var.prefix} CloudFront distribution"
  name_tag             = "${var.prefix}-cdn"
  merged_tags          = merge({ Name = local.name_tag }, var.tags)
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Access identity for ${local.s3_origin_id}"
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = var.enabled
  is_ipv6_enabled = var.enable_ipv6
  comment         = local.distribution_comment

  aliases             = var.aliases
  default_root_object = var.default_root_object
  http_version        = var.http_version
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id != "" ? var.web_acl_id : null

  origin {
    domain_name = var.alb_origin_domain_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port              = var.alb_origin_http_port
      https_port             = var.alb_origin_https_port
      origin_protocol_policy = var.alb_origin_protocol_policy
      origin_ssl_protocols   = var.alb_origin_ssl_protocols
    }
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = var.default_cache_allowed_methods
    cached_methods   = var.default_cache_cached_methods
    target_origin_id = local.alb_origin_id

    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.compress
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

    forwarded_values {
      query_string            = var.forward_query_string
      query_string_cache_keys = var.forward_query_string_cache_keys

      cookies {
        forward           = var.forward_cookies
        whitelisted_names = var.forward_cookies == "whitelist" ? var.forward_cookie_names : []
      }

      headers = var.forward_headers
    }
  }

  ordered_cache_behavior {
    path_pattern     = var.static_path_pattern
    allowed_methods  = var.default_cache_allowed_methods
    cached_methods   = var.default_cache_cached_methods
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.compress
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl

    forwarded_values {
      query_string            = var.forward_query_string
      query_string_cache_keys = var.forward_query_string_cache_keys

      cookies {
        forward           = var.forward_cookies
        whitelisted_names = var.forward_cookies == "whitelist" ? var.forward_cookie_names : []
      }

      headers = var.forward_headers
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_bucket != "" ? [var.logging_bucket] : []
    content {
      bucket          = logging_config.value
      prefix          = var.logging_prefix
      include_cookies = var.logging_include_cookies
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [var.acm_certificate_arn] : []
    content {
      acm_certificate_arn            = viewer_certificate.value
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = var.minimum_protocol_version
      cloudfront_default_certificate = false
    }
  }

  tags = local.merged_tags
}
