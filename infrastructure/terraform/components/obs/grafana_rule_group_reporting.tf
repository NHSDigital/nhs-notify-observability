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
        matchExact       = false
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

    no_data_state  = "OK"
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
        matchExact       = false
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

    no_data_state  = "OK"
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
        matchExact       = false
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

    no_data_state  = "OK"
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
    name      = "S3 Backup Failures"
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
        matchExact       = false
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricName       = "NumberOfBackupJobsFailed"
        metricQueryType  = 0
        namespace        = "AWS/Backup"
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

    no_data_state  = "OK"
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
    name      = "Overdue Request Item Plans"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 3600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = "SELECT MAX(OverdueRequestItemPlansCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
        id               = "max_overdue_request_item_plans_count"
        intervalMs       = 3600000
        label            = ""
        logGroups        = []
        matchExact       = false
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricQueryType  = 0
        metricName       = "OverdueRequestItemPlansCount"
        namespace        = "Notify/Watchdog"
        period           = "3600"
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
        from = 3600
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
        intervalMs     = 3600000
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
        from = 3600
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
        intervalMs    = 3600000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "OK"
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
    name      = "Overdue Request Items"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 3600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = "SELECT MAX(OverdueRequestItemsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
        id               = "max_overdue_request_items_count"
        intervalMs       = 3600000
        label            = ""
        logGroups        = []
        matchExact       = false
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricQueryType  = 0
        metricName       = "OverdueRequestsItemsCount"
        namespace        = "Notify/Watchdog"
        period           = "3600"
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
        from = 3600
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
        intervalMs     = 3600000
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
        from = 3600
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
        intervalMs    = 3600000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "OK"
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
    name      = "Overdue Requests"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 3600
        to   = 0
      }

      datasource_uid = grafana_data_source.cloudwatch_cross_account["reporting"].uid
      model          = jsonencode({
        datasource = {
          type = "cloudwatch"
          uid  = grafana_data_source.cloudwatch_cross_account["reporting"].uid
        }
        expression       = "SELECT MAX(OverdueRequestsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
        id               = "max_overdue_requests_count"
        intervalMs       = 3600000
        label            = ""
        logGroups        = []
        matchExact       = false
        maxDataPoints    = 43200
        metricEditorMode = 0
        metricQueryType  = 0
        metricName       = "OverdueRequestsCount"
        namespace        = "Notify/Watchdog"
        period           = "3600"
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
        from = 3600
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
        intervalMs     = 3600000
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
        from = 3600
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
        intervalMs    = 3600000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state  = "OK"
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
