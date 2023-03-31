# sales api-gateway
resource "aws_apigatewayv2_api" "sales-apigateway" {
  name          = "sales-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "sales-post-integration" {
  api_id           = aws_apigatewayv2_api.sales-apigateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.sales-lambda.invoke_arn
}

resource "aws_apigatewayv2_integration" "sales-get-integration" {
  api_id           = aws_apigatewayv2_api.sales-apigateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.sales-lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "sales-post-route" {
  api_id    = aws_apigatewayv2_api.sales-apigateway.id
  route_key = "POST /checkout"

  target = "integrations/${aws_apigatewayv2_integration.sales-post-integration.id}"
}

resource "aws_apigatewayv2_route" "sales-get-route" {
  api_id    = aws_apigatewayv2_api.sales-apigateway.id
  route_key = "GET /product/donut"

  target = "integrations/${aws_apigatewayv2_integration.sales-get-integration.id}"
}

resource "aws_apigatewayv2_stage" "sales-apigateway-stage" {
  api_id      = aws_apigatewayv2_api.sales-apigateway.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.sales-api-gateway-log.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [aws_cloudwatch_log_group.sales-api-gateway-log]
}

resource "aws_cloudwatch_log_group" "sales-api-gateway-log" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.sales-apigateway.name}"
  retention_in_days = 14
}

#=======================================================================================#
# increse api-gateway
resource "aws_apigatewayv2_api" "increse-apigateway" {
  name          = "increse-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "increse-post-integration" {
  api_id           = aws_apigatewayv2_api.increse-apigateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.increse-lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "increse-post-route" {
  api_id    = aws_apigatewayv2_api.increse-apigateway.id
  route_key = "POST /product/donut"

  target = "integrations/${aws_apigatewayv2_integration.increse-post-integration.id}"
}

resource "aws_apigatewayv2_stage" "increse-apigateway-stage" {
  api_id      = aws_apigatewayv2_api.increse-apigateway.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.increse-api-gateway-log.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [aws_cloudwatch_log_group.increse-api-gateway-log]
}

resource "aws_cloudwatch_log_group" "increse-api-gateway-log" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.increse-apigateway.name}"
  retention_in_days = 14
}

output "sales-api-gateway-url" {
  value = aws_apigatewayv2_api.sales-apigateway.api_endpoint
}

output "increse-api-gateway-url" {
  value = aws_apigatewayv2_api.increse-apigateway.api_endpoint
}