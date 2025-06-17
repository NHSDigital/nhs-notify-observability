locals {
  role_name_pattern = { for id, account_config in var.bounded_context_account_ids : account_config.domain =>
    account_config.override_project_name == "" ?
    "${local.csi}-obs-cross-access-role" :
    "nhs-notify-${var.environment}-obs-cross-access-role"
  }
}
