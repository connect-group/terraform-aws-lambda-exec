locals {
  lambda_source_file = "${local.lambda_source_file_no_ext}.py"
  function_name      = "${local.lambda_source_file_no_ext}_lambda_exec"
}

data "template_file" "lambda_source_file" {
  template = file("${path.module}/${local.lambda_source_file}")

  vars = {
    function_description = "text that is injected into the function"
  }
}

data "archive_file" "lambda_source_file_zip" {
  type        = "zip"
  output_path = "${path.module}/${local.lambda_source_file}.zip"

  source {
    content  = data.template_file.lambda_source_file.rendered
    filename = local.lambda_source_file
  }
}

resource "aws_lambda_function" "lambda" {
  filename = substr(
    data.archive_file.lambda_source_file_zip.output_path,
    length(path.cwd) + 1,
    -1,
  )
  function_name    = local.function_name
  role             = aws_iam_role.lambda.arn
  handler          = "${local.lambda_source_file_no_ext}.handler"
  source_code_hash = data.archive_file.lambda_source_file_zip.output_base64sha256
  runtime          = local.runtime
  timeout          = 15
  description      = "MANAGED BY TERRAFORM"
}

resource "aws_iam_role" "lambda" {
  name = "${local.function_name}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_can_log_and_read_params" {
  name        = "${local.function_name}_policy"
  path        = "/"
  description = "MANAGED BY TERRAFORM Allow Lambda to log"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": ["logs:*"],
          "Resource": "arn:aws:logs:*:*:*"
        },
        {
          "Effect": "Allow",
          "Action": ["ssm:GetParameter"],
          "Resource": "*"
        }
    ]
}
EOF

}

#"Resource": "arn:aws:ssm:*:*:parameter/my_ssm_parameter"

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_can_log_and_read_params.arn
}

