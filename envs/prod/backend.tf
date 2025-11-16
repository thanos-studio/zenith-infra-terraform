terraform {
  backend "s3" {
    bucket = "zenith-tfstate"
    key    = "prod/terraform.tfstate"
    region = "ap-northeast-2"
  }
}