resource "aws_oam_sink" "main" {
  name = "${local.csi}-oam-sink"
  tags  = var.default_tags
}

data "aws_iam_policy_document" "main" {
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

resource "aws_oam_sink_policy" "main" {
  sink_identifier = aws_oam_sink.main.id
  policy          = data.aws_iam_policy_document.oam_sink_policy.json
}
