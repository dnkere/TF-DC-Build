# API Outputs
output "slash_echo_url" {
    value = "${aws_api_gateway_deployment.slash_echo_deployment.invoke_url}/${aws_api_gateway_resource.echo.path_part}"
    description = "The URL that gets configured into Slack to send the POST."
}