# Account Settings
resource "aws_api_gateway_account" "apigw" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch.arn
}

resource "aws_iam_role" "apigateway_cloudwatch" {
  name = "apigateway_cloudwatch_logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "cloudwatch_logs"
  role = aws_iam_role.apigateway_cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


# REST API
resource "aws_api_gateway_rest_api" "slack_slash_commands" {
  name        = "SlackSlashCommands"
  description = "REST API for Slack slash commands"
}

resource "aws_api_gateway_resource" "echo" {
  rest_api_id = aws_api_gateway_rest_api.slack_slash_commands.id
  parent_id   = aws_api_gateway_rest_api.slack_slash_commands.root_resource_id
  path_part   = "echo"
}

resource "aws_api_gateway_method" "echo" {
  rest_api_id   = aws_api_gateway_rest_api.slack_slash_commands.id
  resource_id   = aws_api_gateway_resource.echo.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "echo_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.slack_slash_commands.id
  resource_id             = aws_api_gateway_resource.echo.id
  http_method             = aws_api_gateway_method.echo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.slash_echo.invoke_arn
}

resource "aws_api_gateway_deployment" "slash_echo_deployment" {
  depends_on = [aws_api_gateway_integration.echo_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.slack_slash_commands.id
  stage_name  = var.stage
}