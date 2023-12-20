resource "azurerm_resource_group" "slash_echo" {
  name     = "slash-echo-rg"
  location = var.region
}

resource "azurerm_app_service_plan" "slash_echo" {
  name                = "slash_echo-service-plan"
  location            = azurerm_resource_group.slash_echo.location
  resource_group_name = azurerm_resource_group.slash_echo.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "slash_echo" {
  name                      = "slash-echo"
  location                  = azurerm_resource_group.slash_echo.location
  resource_group_name       = azurerm_resource_group.slash_echo.name
  app_service_plan_id       = azurerm_app_service_plan.slash_echo.id
  storage_connection_string = azurerm_storage_account.slash_echo.primary_connection_string
  version                   = "~2"

  app_settings = {
      APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.slash_echo.instrumentation_key
      WEBSITE_RUN_FROM_PACKAGE       = "https://${azurerm_storage_account.slash_echo.name}.blob.core.windows.net/${azurerm_storage_container.slash_echo.name}/${azurerm_storage_blob.slash_echo.name}${data.azurerm_storage_account_sas.slash_echo.sas}"
      slack_verification_token       = azurerm_key_vault_secret.slack_verification_token.value
  }

  depends_on = [
    azurerm_storage_blob.slash_echo,
  ]
}

resource "azurerm_application_insights" "slash_echo" {
  name                = "slash-echo-appinsights"
  location            = azurerm_resource_group.slash_echo.location
  resource_group_name = azurerm_resource_group.slash_echo.name
  application_type    = "web"
}