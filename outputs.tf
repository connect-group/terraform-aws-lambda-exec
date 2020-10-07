output "result" {
  description = "A map of results returned by the Lambda, based on the input variable 'lambda_outputs'"
  value       = aws_cloudformation_stack.execute_lambda.outputs
}

