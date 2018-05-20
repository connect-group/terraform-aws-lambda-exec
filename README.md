AWS Lambda Exec Module
======================
This module will execute a Lambda function and return its result(s).  It allows Lambdas to be used as a form of Data Source (via a resource) but it also allows them to perform other functions upon e.g. when destroy is called.

There are some very specific constraints on how the Lambda function should work: under the hood it is using a 
CloudFormation "[CustomResource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html)" to execute the Lambda.

Possible uses include,
* Advanced AMI Queries: look for an AMI but return a default if not found;
* Get an SSM Parameter but return a default if it is not found [(see this example)](https://github.com/connect-group/terraform-aws-lambda-exec/tree/master/examples/python_get_ssm_parameter)
* Get the latest RDS Snapshot Identifier, but return an empty string if it does not exist


Usage
-----
If your Lambda function has inputs, pass them using the `lambda_inputs` map.  The actual inputs you pass will depend on the
lambda function being run.

If your Lambda function has outputs, specify them with the `lambda_outputs` array.  IMPORTANT: the lambda MUST return these
outputs or else Cloudformation will rollback.  So even if you want to return an error you must return (an empty) value
for all inputs.


```hcl
data "aws_lambda_function" "my_ami_query" {
  name="my_ami_query"
}

module "execute" {
  source="connect-group/lambda-exec/aws"
  name                = "my_lambda_execution"
  lambda_function_arn = "${data.aws_lambda_function.lambda.arn}"

  lambda_inputs = {
    ami_tag = "tag"
  }

  lambda_outputs = [
    "ami_id",
    "Error",
  ]
}
```

Run the Lambda on every Apply
-----------------------------
If you wish to run the Lambda on every Apply, then you need to insert an input that changes
on every apply: typically using the timestamp() interpolation function.

```hcl
module "execute_lambda" {
  ...

  lambda_inputs = {
    run_on_every_apply = "${timestamp()}"
  }

  ...
}
```

Writing a Compatible Lambda
---------------------------
* Inputs to the Lambda function are supplied in the Lambda event['ResourceProperties'] object
* You should return the same set of outputs on success and on error, as Cloudformation will generate an unrecoverable error if a result is missing from the outputs.
* You must send the result of the lambda to a signed URL - you can't just return a result.  Take a look at the examples!
* Outputs can only be strings, not maps or lists.
* You can detect if the CloudFormation stack is being updated or destroyed and respond accordingly.  The event['RequestType'] indicates the status,
  * Create
  * Update
  * Delete


Examples
--------
* [Node.js Reverse input strings](https://github.com/connect-group/terraform-aws-lambda-exec/tree/master/examples/node)
* [Python Get SSM Parameter or return default](https://github.com/connect-group/terraform-aws-lambda-exec/tree/master/examples/python_get_ssm_parameter)
* For a Java example, see [cloudformation-custom-resources](https://github.com/stelligent/cloudformation-custom-resources) on GitHub

Authors
-------
Currently maintained by [these awesome contributors](https://github.com/connect-group/terraform-aws-lambda-exec/graphs/contributors).
Module managed by [Adam Perry](https://github.com/4dz) and [Connect Group](https://github.com/connect-group)

License
-------
Apache 2 Licensed. See LICENSE for full details.