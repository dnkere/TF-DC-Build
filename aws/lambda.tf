# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slash_echo.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.slack_slash_commands.id}/*/${aws_api_gateway_method.echo.http_method}${aws_api_gateway_resource.echo.path}"
}

resource "aws_lambda_function" "slash_echo" {
  filename      = "src/slash-echo.zip"
  function_name = "slash_echo"
  role          = aws_iam_role.iam_lambda_slash_echo.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.8"
  kms_key_arn   = aws_kms_key.slash_echo_kms.arn

  source_code_hash = filebase64sha256("src/slash-echo.zip")

  environment {
    variables = {
      slack_verification_token = aws_ssm_parameter.slack_verification_token.value
    }
  }
}


# IAM
resource "aws_iam_role" "iam_lambda_slash_echo" {
  name = "lambda-slash-echo"

  assume_role_policy = <<-EOF
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

resource "aws_iam_role_policy" "lambda_cloudwatch_logs" {
  name = "lambda_cloudwatch_logs"
  role = aws_iam_role.iam_lambda_slash_echo.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "arn:aws:logs:us-east-1:966064235577:*"
      },
      {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": [
            "arn:aws:logs::log-group:/aws/lambda/${aws_lambda_function.slash_echo.function_name}:*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "lambda_encrypt_decrypt" {
  name = "lambda_encrypt_decrypt"
  role = aws_iam_role.iam_lambda_slash_echo.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
              "kms:Decrypt",
              "kms:Encrypt"
          ],
          "Resource": "${aws_kms_key.slash_echo_kms.arn}"
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "slash_echo_lambda_vpc" {
  role       = aws_iam_role.iam_lambda_slash_echo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}