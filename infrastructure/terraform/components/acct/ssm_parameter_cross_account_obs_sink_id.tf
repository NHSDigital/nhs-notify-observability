resource "aws_ssm_parameter" "cross_account_obs_sink_id" {
  name        = "/oam_sink/cross_account_obs/sink_id"
  description = "The sink_id of the cross_account_obs OAM sink"
  type        = "String"
  value       = aws_oam_sink.cross_account_obs.id
}

resource "aws_ram_resource_share" "ssm_parameter_share" {
  name                      = "CrossAccountSSMParameterShare"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "ssm_parameter_association" {
  resource_share_arn = aws_ram_resource_share.ssm_parameter_share.arn
  resource_arn       = aws_ssm_parameter.cross_account_obs_sink_id.arn
}

resource "aws_ram_principal_association" "principal_associations" {
  for_each           = toset(var.bounded_context_account_ids[*].account_id)
  principal          = each.key
  resource_share_arn = aws_ram_resource_share.ssm_parameter_share.arn
}
