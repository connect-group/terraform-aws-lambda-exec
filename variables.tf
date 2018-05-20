variable "lambda_inputs" {
  default     = {}
  type        = "map"
  description = "Map of inputs which are passed into the Lambda function via the event['ResourceProperties'] object."
}

variable "lambda_outputs" {
  type        = "list"
  description = "List of outputs from the Lambda function.  The Lambda must ALWAYS return these outputs, and they can only be of type String.  Maps/Objects will result in a CloudFormation error."
}

variable "tags" {
  default     = {}
  type        = "map"
  description = "Any tags to add to the CloudFormation stack."
}

variable "name" {
  description = "Unique name for the result of executing the lambda."
}

variable "lambda_function_arn" {
  description = "Lambda ARN - identify the lambda to execute."
}

variable "timeout_in_minutes" {
  default     = "2"
  description = "Maximum Time to wait for a response from CloudFormation/Lambda.  The Lambda itself may have its own timeout; this does not override it."
}
