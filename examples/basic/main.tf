# Basic Example - Minimal Configuration
# This example shows the simplest way to use the tenx-streamer-infra module
# with default settings for all three queues and S3 indexing.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "tenx_streamer_infra" {
  source  = "log-10x/tenx-streamer-infra/aws"
  version = "~> 0.1"

  # Use default queue names (my-index-queue, my-query-queue, my-pipeline-queue)
  # Use default S3 bucket configuration (creates my-tenx-index-bucket)

  tenx_streamer_user_supplied_tags = {
    Environment = "development"
    Project     = "10x-streamer"
  }
}

# Outputs for Quarkus application configuration
output "index_queue_url" {
  description = "Use this for TENX_QUARKUS_SQS_INDEX_QUEUE_URL"
  value       = module.tenx_streamer_infra.index_queue_url
}

output "query_queue_url" {
  description = "Use this for TENX_QUARKUS_SQS_QUERY_QUEUE_URL"
  value       = module.tenx_streamer_infra.query_queue_url
}

output "pipeline_queue_url" {
  description = "Use this for TENX_QUARKUS_SQS_PIPELINE_QUEUE_URL"
  value       = module.tenx_streamer_infra.pipeline_queue_url
}

output "index_write_container" {
  description = "Use this for TENX_QUARKUS_SQS_INDEX_WRITE_CONTAINER"
  value       = module.tenx_streamer_infra.index_write_container
}
