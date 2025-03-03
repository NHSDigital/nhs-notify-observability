resource "grafana_rule_group" "reporting" {
  name             = "Reporting Alerts - (${var.environment})"
  folder_uid       = "${local.csi}-reporting"
  interval_seconds = 3600

  rule {
    name      = "Executions Aborted"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = ""
        id               = ""
        intervalMs       = 1000
        label            = ""
        logGroups        = []
        matchExact       = true
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricName       = "ExecutionsAborted"
        metricQueryType  = 0
        namespace        = "AWS/States"
        period           = "60"
        queryMode        = "Metrics"
        refId            = "A"
        region           = "default"
        sqlExpression    = ""
        statistic        = "Sum"
      })
    }

    data {
      ref_id = "B"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [1], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["A"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression     = "A"
        intervalMs     = 1000
        maxDataPoints  = 43200
        reducer        = "last"
        refId          = "B"
        settings       = { mode = "" }
        type           = "reduce"
      })
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [0], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["B"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "B"
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1h"
    annotations    = {}
    labels         = {}
    is_paused      = false

    notification_settings {
      contact_point = grafana_contact_point.sns.name
      group_by      = null
      mute_timings  = null
    }
  }

  rule {
    name      = "Executions Failed"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = ""
        id               = ""
        intervalMs       = 1000
        label            = ""
        logGroups        = []
        matchExact       = true
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricName       = "ExecutionsFailed"
        metricQueryType  = 0
        namespace        = "AWS/States"
        period           = "60"
        queryMode        = "Metrics"
        refId            = "A"
        region           = "default"
        sqlExpression    = ""
        statistic        = "Sum"
      })
    }

    data {
      ref_id = "B"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [1], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["A"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression     = "A"
        intervalMs     = 1000
        maxDataPoints  = 43200
        reducer        = "last"
        refId          = "B"
        settings       = { mode = "" }
        type           = "reduce"
      })
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [0], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["B"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "B"
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1h"
    annotations    = {}
    labels         = {}
    is_paused      = false

    notification_settings {
      contact_point = grafana_contact_point.sns.name
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "Executions Timed Out"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = ""
        id               = ""
        intervalMs       = 1000
        label            = ""
        logGroups        = []
        matchExact       = true
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricName       = "ExecutionsTimedOut"
        metricQueryType  = 0
        namespace        = "AWS/States"
        period           = "60"
        queryMode        = "Metrics"
        refId            = "A"
        region           = "default"
        sqlExpression    = ""
        statistic        = "Sum"
      })
    }

    data {
      ref_id = "B"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [1], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["A"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression     = "A"
        intervalMs     = 1000
        maxDataPoints  = 43200
        reducer        = "last"
        refId          = "B"
        settings       = { mode = "" }
        type           = "reduce"
      })
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [{
          evaluator = { params = [0], type = "gt" }
          operator  = { type = "and" }
          query     = { params = ["B"] }
          reducer   = { params = [], type = "last" }
          type      = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "B"
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1h"
    annotations    = {}
    labels         = {}
    is_paused      = false

    notification_settings {
      contact_point = grafana_contact_point.sns.name
      group_by      = null
      mute_timings  = null
    }
  }
}
