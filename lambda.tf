# sales lambda
resource "aws_iam_role" "iam_for_sales_lambda" {
  name = "iam_for_sales_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "sales_lambda_dir_zip" {
  type        = "zip"
  output_path = "/tmp/sales_lambda_dir_zip.zip"
  source_dir  = "./sales_src"
}

resource "aws_lambda_function" "sales-lambda" {
  filename         = data.archive_file.sales_lambda_dir_zip.output_path
  source_code_hash = data.archive_file.sales_lambda_dir_zip.output_base64sha256
  function_name    = var.sales_lambda_function_name
  role             = aws_iam_role.iam_for_sales_lambda.arn
  handler          = "handler.handler"

  runtime = "nodejs14.x"

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.user_updates.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.sales-lambda-log]
}

resource "aws_lambda_function_event_invoke_config" "sales-lambda-config" {
  function_name = aws_lambda_function.sales-lambda.function_name

  destination_config {
    on_success {
      destination = aws_sns_topic.user_updates.arn
    }
  }
}

resource "aws_cloudwatch_log_group" "sales-lambda-log" {
  name              = "/aws/lambda/${var.sales_lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "sales-lambda-policy" {
  name        = "sales-lambda-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sales-lambda-policy-attch" {
  role       = aws_iam_role.iam_for_sales_lambda.name
  policy_arn = aws_iam_policy.sales-lambda-policy.arn
}

resource "aws_lambda_permission" "sales-lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sales-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.sales-apigateway.execution_arn}/*"
}

#=======================================================================================#
# factory lambda
resource "aws_iam_role" "iam_for_factory_lambda" {
  name = "iam_for_factory_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "factory_lambda_dir_zip" {
  type        = "zip"
  output_path = "/tmp/factory_lambda_dir_zip.zip"
  source_dir  = "./factory_src"
}

resource "aws_lambda_function" "factory-lambda" {
  filename         = data.archive_file.factory_lambda_dir_zip.output_path
  source_code_hash = data.archive_file.factory_lambda_dir_zip.output_base64sha256
  function_name    = var.factory_lambda_function_name
  role             = aws_iam_role.iam_for_factory_lambda.arn
  handler          = "index.consumer"

  runtime = "nodejs14.x"

  environment {
    variables = {
      CALLBACK_URL = aws_apigatewayv2_api.increse-apigateway.api_endpoint
    }
  }

  depends_on = [aws_cloudwatch_log_group.factory-lambda-log]
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.stock_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.factory-lambda.function_name
  batch_size       = 10
}

resource "aws_cloudwatch_log_group" "factory-lambda-log" {
  name              = "/aws/lambda/${var.factory_lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "factory-lambda-policy" {
  name        = "factory-lambda-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": ["arn:aws:sqs:*"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "factory-lambda-policy-attch" {
  role       = aws_iam_role.iam_for_factory_lambda.name
  policy_arn = aws_iam_policy.factory-lambda-policy.arn
}

#=======================================================================================#
# increse lambda
resource "aws_iam_role" "iam_for_increse_lambda" {
  name = "iam_for_increse_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "increse_lambda_dir_zip" {
  type        = "zip"
  output_path = "/tmp/increse_lambda_dir_zip.zip"
  source_dir  = "./increse_src"
}

resource "aws_lambda_function" "increse-lambda" {
  filename         = data.archive_file.increse_lambda_dir_zip.output_path
  source_code_hash = data.archive_file.increse_lambda_dir_zip.output_base64sha256
  function_name    = var.increse_lambda_function_name
  role             = aws_iam_role.iam_for_increse_lambda.arn
  handler          = "handler.handler"

  runtime = "nodejs14.x"

  depends_on = [aws_cloudwatch_log_group.increse-lambda-log]
}

resource "aws_cloudwatch_log_group" "increse-lambda-log" {
  name              = "/aws/lambda/${var.increse_lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "increse-lambda-policy" {
  name        = "increse-lambda-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "increse-lambda-policy-attch" {
  role       = aws_iam_role.iam_for_increse_lambda.name
  policy_arn = aws_iam_policy.increse-lambda-policy.arn
}

resource "aws_lambda_permission" "increse-lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.increse-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.increse-apigateway.execution_arn}/*"
}