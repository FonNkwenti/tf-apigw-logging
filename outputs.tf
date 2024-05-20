output "claim_url" {
  description = "The API Gateway invocation url pointing to the stage"
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}/${aws_api_gateway_resource.claim.path_part}"
}

