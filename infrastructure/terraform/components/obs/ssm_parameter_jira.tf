resource "aws_ssm_parameter" "jira_url" {
  name  = "/notify/jira/url"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "jira_pat_token" {
  name  = "/notify/jira/pat/token"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}
