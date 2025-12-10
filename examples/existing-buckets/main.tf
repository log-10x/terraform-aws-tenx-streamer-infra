# Existing Buckets Example
# This example shows how to use the module with existing S3 buckets
# instead of creating new ones.

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

# Reference existing S3 buckets
data "aws_s3_bucket" "existing_source" {
  bucket = "my-existing-logs-bucket"
}

data "aws_s3_bucket" "existing_results" {
  bucket = "my-existing-results-bucket"
}

module "tenx_streamer_infra" {
  source  = "log-10x/tenx-streamer-infra/aws"
  version = "~> 0.1"

  # Queue configuration
  tenx_streamer_index_queue_name    = "my-index-queue"
  tenx_streamer_query_queue_name    = "my-query-queue"
  tenx_streamer_pipeline_queue_name = "my-pipeline-queue"

  # Use existing S3 buckets - do NOT create new ones
  tenx_streamer_create_index_source_bucket  = false
  tenx_streamer_create_index_results_bucket = false

  tenx_streamer_index_source_bucket_name  = data.aws_s3_bucket.existing_source.id
  tenx_streamer_index_results_bucket_name = data.aws_s3_bucket.existing_results.id
  tenx_streamer_index_results_path        = "tenx-indexing/"

  # Custom trigger configuration
  tenx_streamer_index_trigger_prefix = "data/"
  tenx_streamer_index_trigger_suffix = ".log"

  tenx_streamer_user_supplied_tags = {
    Environment = "staging"
    Project     = "10x-streamer"
  }
}

# Outputs
output "index_queue_url" {
  description = "Index queue URL"
  value       = module.tenx_streamer_infra.index_queue_url
}

output "query_queue_url" {
  description = "Query queue URL"
  value       = module.tenx_streamer_infra.query_queue_url
}

output "pipeline_queue_url" {
  description = "Pipeline queue URL"
  value       = module.tenx_streamer_infra.pipeline_queue_url
}

output "index_write_container" {
  description = "Index write container"
  value       = module.tenx_streamer_infra.index_write_container
}
