# This example uses locals which were introduced in Terrform 0.10
terraform {
  required_version = ">=0.10.4"
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  lambda_source_file_no_ext = "node_sample"
  runtime                   = "nodejs12.x"
}

module "execute" {
  source              = "../../"
  name                = "${replace(local.lambda_source_file_no_ext, "_", "-")}-example"
  lambda_function_arn = aws_lambda_function.lambda.arn

  lambda_inputs = {
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    digits   = "0123456789"
  }

  lambda_outputs = [
    "alphabet",
    "digits",
    "Timestamp",
    "Error",
  ]
}

