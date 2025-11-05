resource "aws_cloudwatch_event_rule" "env_destroy" {
  name           = "${local.csi}-env-destroy"
  event_bus_name = data.terraform_remote_state.acct.outputs.acct_event_bus_name
  description    = "Triggers Lambda when an env destroy event is received"

  event_pattern = jsonencode({
    source        = ["notify.envDestroyFailed"]
  })
}
