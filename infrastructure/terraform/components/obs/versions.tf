terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }

    grafana = {
      source  = "grafana/grafana"
      version = ">= 3.18.3"
    }
  }

  required_version = ">= 1.9.0"
}
