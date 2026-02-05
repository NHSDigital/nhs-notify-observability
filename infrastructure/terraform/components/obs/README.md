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
| <a name="input_bounded_context_account_ids"></a> [bounded\_context\_account\_ids](#input\_bounded\_context\_account\_ids) | A list of accounts Grafana can assume role into | <pre>list(object({<br/>    domain                = string<br/>    account_id            = string<br/>    override_project_name = optional(string, "") # Optional override for Legacy Project Name used in Core/DNS<br/>  }))</pre> | `[]` | no |
| <a name="input_component"></a> [component](#input\_component) | The variable encapsulating the name of this component | `string` | `"obs"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_delegated_grafana_admin_group_ids"></a> [delegated\_grafana\_admin\_group\_ids](#input\_delegated\_grafana\_admin\_group\_ids) | A list of SSO group ids that would be granted ADMIN access in Grafana | `list(string)` | n/a | yes |
| <a name="input_delegated_grafana_editor_group_ids"></a> [delegated\_grafana\_editor\_group\_ids](#input\_delegated\_grafana\_editor\_group\_ids) | A list of SSO group ids that would be granted EDITOR access in Grafana | `list(string)` | n/a | yes |
| <a name="input_delegated_grafana_viewer_group_ids"></a> [delegated\_grafana\_viewer\_group\_ids](#input\_delegated\_grafana\_viewer\_group\_ids) | A list of SSO group ids that would be granted VIEWER access in Grafana | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_force_lambda_code_deploy"></a> [force\_lambda\_code\_deploy](#input\_force\_lambda\_code\_deploy) | If the lambda package in s3 has the same commit id tag as the terraform build branch, the lambda will not update automatically. Set to True if making changes to Lambda code from on the same commit for example during development | `bool` | `false` | no |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | n/a | yes |
| <a name="input_kms_deletion_window"></a> [kms\_deletion\_window](#input\_kms\_deletion\_window) | When a kms key is deleted, how long should it wait in the pending deletion state? | `string` | `"30"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | The log level to be used in lambda functions within the component. Any log with a lower severity than the configured value will not be logged: https://docs.python.org/3/library/logging.html#levels | `string` | `"INFO"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite | `number` | `0` | no |
| <a name="input_parent_acct_environment"></a> [parent\_acct\_environment](#input\_parent\_acct\_environment) | Name of the environment responsible for the acct resources used, affects things like DNS zone. Useful for named dev environments | `string` | `"main"` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | The service's root DNS root nameespace, like nonprod.nhsnotify.national.nhs.uk | `string` | `"nonprod.nhsnotify.national.nhs.uk"` | no |
| <a name="input_ship_logs_to_splunk"></a> [ship\_logs\_to\_splunk](#input\_ship\_logs\_to\_splunk) | Whether to ship logs to Splunk via Kinesis Firehose. Set to false for dev environments to save costs. | `bool` | `true` | no |
| <a name="input_ship_metrics_to_splunk"></a> [ship\_metrics\_to\_splunk](#input\_ship\_metrics\_to\_splunk) | Whether to ship metrics to Splunk via Kinesis Firehose. Set to false for dev environments to save costs. | `bool` | `true` | no |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kinesis_firehose_to_splunk_logs"></a> [kinesis\_firehose\_to\_splunk\_logs](#module\_kinesis\_firehose\_to\_splunk\_logs) | ../../modules/kinesis-firehose-to-splunk | n/a |
| <a name="module_kinesis_firehose_to_splunk_metrics"></a> [kinesis\_firehose\_to\_splunk\_metrics](#module\_kinesis\_firehose\_to\_splunk\_metrics) | ../../modules/kinesis-firehose-to-splunk | n/a |
| <a name="module_kinesis_firehose_to_splunk_metrics_us"></a> [kinesis\_firehose\_to\_splunk\_metrics\_us](#module\_kinesis\_firehose\_to\_splunk\_metrics\_us) | ../../modules/kinesis-firehose-to-splunk | n/a |
| <a name="module_kms_logs"></a> [kms\_logs](#module\_kms\_logs) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-kms.zip | n/a |
| <a name="module_kms_splunk"></a> [kms\_splunk](#module\_kms\_splunk) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-kms.zip | n/a |
| <a name="module_lambda_alert_forwarding"></a> [lambda\_alert\_forwarding](#module\_lambda\_alert\_forwarding) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip | n/a |
| <a name="module_s3bucket_splunk_firehose"></a> [s3bucket\_splunk\_firehose](#module\_s3bucket\_splunk\_firehose) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-s3bucket.zip | n/a |
| <a name="module_s3bucket_splunk_firehose_us"></a> [s3bucket\_splunk\_firehose\_us](#module\_s3bucket\_splunk\_firehose\_us) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-s3bucket.zip | n/a |
| <a name="module_splunk_logs_formatter_lambda"></a> [splunk\_logs\_formatter\_lambda](#module\_splunk\_logs\_formatter\_lambda) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip | n/a |
| <a name="module_splunk_metrics_formatter_lambda"></a> [splunk\_metrics\_formatter\_lambda](#module\_splunk\_metrics\_formatter\_lambda) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip | n/a |
| <a name="module_splunk_metrics_formatter_lambda_us"></a> [splunk\_metrics\_formatter\_lambda\_us](#module\_splunk\_metrics\_formatter\_lambda\_us) | https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip | n/a |
## Outputs

No outputs.
<!-- vale on -->
<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->
