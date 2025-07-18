##
# Basic Required Variables for tfscaffold Components
##

variable "project" {
  type        = string
  description = "The name of the tfscaffold project"
}

variable "environment" {
  type        = string
  description = "The name of the tfscaffold environment"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID (numeric)"
}

variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
}

##
# tfscaffold variables specific to this component
##

# This is the only primary variable to have its value defined as
# a default within its declaration in this file, because the variables
# purpose is as an identifier unique to this component, rather
# then to the environment from where all other variables come.
variable "component" {
  type        = string
  description = "The variable encapsulating the name of this component"
  default     = "acct"
}

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the component"
  default     = {}
}

##
# Variables specific to the "dnsroot"component
##

variable "log_retention_in_days" {
  type        = number
  description = "The retention period in days for the Cloudwatch Logs events to be retained, default of 0 is indefinite"
  default     = 0
}

variable "type" {
  type        = string
  description = "The type of the resource - logs or metrics"
  default     = null

  validation {
    condition     = var.type == "logs" || var.type == "metrics"
    error_message = "The 'type' variable must be either 'logs' or 'metrics'."
  }

}

variable "kms_splunk_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encrypting the Splunk Firehose data"
  default     = null
}

variable "splunk_firehose_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to use for the Splunk Firehose data"
  default     = null
}

variable "formatter_lambda_buffer" {
  description = "Formatter lambda buffer size"
  default     = 1 # Megabytes (Maximum 3)
}

variable "formatter_lambda_buffer_interval" {
  description = "Buffer for formatter lambda for the specified period of time, in seconds, before delivering it to the lambda"
  default     = 60 # Seconds (Maximum 900)
}

variable "formatter_lambda_function_arn" {
  type        = string
  description = "Formatter function arn"
  default     = ""
}

variable "kinesis_firehose_buffer" {
  description = "https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#buffer_size"
  default     = 5 # Megabytes (Maximum 5)
}

variable "kinesis_firehose_buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination"
  default     = 60 # Seconds (Maximum 60)
}

variable "s3_kinesis_firehose_buffer" {
  description = "S3 backup buffer"
  default     = 5 # Megabytes (Maximum 128)
}

variable "s3_kinesis_firehose_buffer_interval" {
  description = "S3 backup buffer interval"
  default     = 300 # Seconds (Maximum 900)
}

variable "region_prefix" {
  type        = string
  description = "The prefix to use for the region in the resource names"
  default     = ""
}
