# This example uses locals which were introduced in Terrform 0.10
terraform {
  required_version = ">=0.10.4"
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  lambda_source_file_no_ext = "python_sample"
  runtime                   = "python2.7"
}

module "execute" {
  source              = "../../"
  name                = "${replace(local.lambda_source_file_no_ext, "_", "-")}-example"
  lambda_function_arn = aws_lambda_function.lambda.arn

  lambda_inputs = {
    parameter_name     = "my_ssm_parameter"
    default_value      = "not found"
    run_on_every_apply = timestamp()
  }

  lambda_outputs = [
    "value",
    "Error",
  ]
}

