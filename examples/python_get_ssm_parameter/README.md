Read an SSM Parameter or return a Default (Python)
==================================================
This example attempts to read an SSM parameter called 'my_ssm_parameter'.  
If it does not exist it will return a default value.

It is unlikely to exist, so it will return a default value of 'not found'.

To add a value which it can read, execute the following:

```bash
$ aws ssm put-parameter --name "my_ssm_parameter" --type="String" --overwrite --value "this is a real value"
```

Then run `terraform apply` to confirm that the module retrieves the SSM Paramater value.

To delete the parameter again,

```bash
$ aws ssm delete-parameter --name "my_ssm_parameter"
```

Usage
-----
```hcl
module "execute" {
  source              = "../../"
  name                = "python-sample-example"
  lambda_function_arn = "${aws_lambda_function.lambda.arn}"

  lambda_inputs = {
    parameter_name     = "my_ssm_parameter"
    default_value      = "not found"
    run_on_every_apply = "${timestamp()}"
  }

  lambda_outputs = [
    "value",
    "Error",
  ]
}
```

Outputs
-------
```
Outputs:

result = {
  Error =
  value = this is a real value too
}
```