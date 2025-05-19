<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
<!-- vale off -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.50 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_bounded_context_account_ids"></a> [bounded\_context\_account\_ids](#input\_bounded\_context\_account\_ids) | A list of bounded context account ids | <pre>list(object({<br/>    domain     = string<br/>    account_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"acct"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_kms_deletion_window"></a> [kms\_deletion\_window](#input\_kms\_deletion\_window) | When a kms key is deleted, how long should it wait in the pending deletion state? | `string` | `"30"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite | `number` | `0` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | The service's root DNS root nameespace, like nonprod.nhsnotify.national.nhs.uk | `string` | `"nonprod.nhsnotify.national.nhs.uk"` | no |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kinesis_firehose_to_splunk_logs"></a> [kinesis\_firehose\_to\_splunk\_logs](#module\_kinesis\_firehose\_to\_splunk\_logs) | ../../modules/kinesis-firehose-to-splunk | n/a |
| <a name="module_kinesis_firehose_to_splunk_metrics"></a> [kinesis\_firehose\_to\_splunk\_metrics](#module\_kinesis\_firehose\_to\_splunk\_metrics) | ../../modules/kinesis-firehose-to-splunk | n/a |
| <a name="module_kms_logs"></a> [kms\_logs](#module\_kms\_logs) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/kms | v1.0.8 |
| <a name="module_kms_splunk"></a> [kms\_splunk](#module\_kms\_splunk) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/kms | v1.0.9 |
| <a name="module_s3bucket_access_logs"></a> [s3bucket\_access\_logs](#module\_s3bucket\_access\_logs) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/s3bucket | v1.0.8 |
| <a name="module_s3bucket_lambda_artefacts"></a> [s3bucket\_lambda\_artefacts](#module\_s3bucket\_lambda\_artefacts) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/s3bucket | v1.0.0 |
| <a name="module_s3bucket_splunk_firehose"></a> [s3bucket\_splunk\_firehose](#module\_s3bucket\_splunk\_firehose) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/s3bucket | v1.0.0 |
| <a name="module_splunk_logs_formatter_lambda"></a> [splunk\_logs\_formatter\_lambda](#module\_splunk\_logs\_formatter\_lambda) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda | v2.0.6 |
| <a name="module_splunk_metrics_formatter_lambda"></a> [splunk\_metrics\_formatter\_lambda](#module\_splunk\_metrics\_formatter\_lambda) | git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda | v2.0.6 |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone"></a> [dns\_zone](#output\_dns\_zone) | n/a |
| <a name="output_event_bus_arn"></a> [event\_bus\_arn](#output\_event\_bus\_arn) | n/a |
| <a name="output_event_bus_name"></a> [event\_bus\_name](#output\_event\_bus\_name) | n/a |
| <a name="output_s3_buckets"></a> [s3\_buckets](#output\_s3\_buckets) | n/a |
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
