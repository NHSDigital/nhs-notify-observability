<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

No requirements.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"acct"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_firehose_to_s3_role_arn"></a> [firehose\_to\_s3\_role\_arn](#input\_firehose\_to\_s3\_role\_arn) | The ARN of the IAM role to use for the Splunk Firehose to S3 | `string` | `null` | no |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_kms_splunk_key_arn"></a> [kms\_splunk\_key\_arn](#input\_kms\_splunk\_key\_arn) | The ARN of the KMS key to use for encrypting the Splunk Firehose data | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite | `number` | `0` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_splunk_firehose_bucket_arn"></a> [splunk\_firehose\_bucket\_arn](#input\_splunk\_firehose\_bucket\_arn) | The ARN of the S3 bucket to use for the Splunk Firehose data | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of the resource - logs or metrics | `string` | `null` | no |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose delivery stream |
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
