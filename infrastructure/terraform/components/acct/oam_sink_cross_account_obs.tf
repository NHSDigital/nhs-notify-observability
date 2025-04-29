resource "aws_oam_sink" "cross_account_obs" {
  name = "${local.csi}-oam-sink"
  tags  = var.default_tags
}

data "aws_iam_policy_document" "cross_account_obs" {
  statement {
    actions   = ["oam:CreateLink", "oam:UpdateLink"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = var.delegated_grafana_account_ids[*].account_id
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "oam:ResourceTypes"
      values   = [
        "AWS::CloudWatch::Metric",
        "AWS::CloudWatch::Log"
      ]
    }
  }
}

resource "aws_oam_sink_policy" "cross_account_obs" {
  sink_identifier = aws_oam_sink.cross_account_obs.id
  policy          = data.aws_iam_policy_document.cross_account_obs.json
}
