#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = "claims-api"
  description = "Private API for claims service"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

# API Gateway claim resource
resource "aws_api_gateway_resource" "claim" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "claim"
}
# API Gateway resource for /claim/{id}
resource "aws_api_gateway_resource" "claim_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.claim.id
  path_part   = "{id}"
}


#  api gateway deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
  aws_api_gateway_integration.post_claim_lambda
  ]

  triggers = {
    redeployment = sha1(jsonencode ([
        aws_api_gateway_resource.claim.id,
        aws_api_gateway_resource.claim_id.id,
        aws_api_gateway_method.post_claim.id,
        aws_api_gateway_integration.post_claim_lambda.id,

      ]))
    
  }

    lifecycle {
    create_before_destroy = true
  }

}


# api gateway stage for dev
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "${var.stage_name}"

    access_log_settings {
    destination_arn = aws_cloudwatch_log_group.claim.arn
    format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
  depends_on = [aws_api_gateway_account.this]
  
}
## HTTP methods for the claim and claim_id resources
resource "aws_api_gateway_method" "post_claim" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "post_claim_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    logging_level        = "INFO"
    data_trace_enabled   = true
    metrics_enabled      = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

# resource "aws_api_gateway_method" "any_claim" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = aws_api_gateway_resource.claim.id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

## api gateway lambda proxy integrations 

resource "aws_api_gateway_integration" "post_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.claim.id
  http_method = aws_api_gateway_method.post_claim.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createClaim.invoke_arn
}

# resource "aws_api_gateway_integration" "any_claim" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   resource_id = aws_api_gateway_resource.claim.id
#   http_method = aws_api_gateway_method.any_claim.http_method
#   type                    = "MOCK"

# }



# cloudwatch log group for API Gateway logs 
resource "aws_cloudwatch_log_group" "claim" {
  # name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/dev"
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${var.stage_name}"
  retention_in_days = 7

}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_exec_role.arn
}

resource "aws_iam_role" "apigw_exec_role" {
  name = "apigw-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch" {
  role = aws_iam_role.apigw_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  
}


# Mandatory apigw resource policy for private APIs
# resource "aws_api_gateway_rest_api_policy" "claim_policy" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   policy      = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": "*",
#         "Action": "execute-api:Invoke",
#         "Resource": "${aws_api_gateway_rest_api.this.execution_arn}*"
#       },
#       {
#               "Effect": "Deny",
#               "Principal": "*",
#               "Action": "execute-api:Invoke",
#               "Resource": "${aws_api_gateway_rest_api.this.execution_arn}*",
#               "Condition": {
#                   "StringNotEquals": {
#                       "aws:SourceVpce": "${aws_vpc_endpoint.execute_api_ep.id}"
#                   }
#               }
#           }
#     ]
#   })
# }

