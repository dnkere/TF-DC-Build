# API Outputs
output "slash_echo_url" {
    value       = "${azurerm_function_app.slash_echo.default_hostname}/api/${azurerm_function_app.slash_echo.name}"
    description = "The URL that gets configured into Slack to send the POST."
}