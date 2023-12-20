resource "azurerm_key_vault" "slash_echo" {
  name                        = "slash-echo-vault"
  location                    = azurerm_resource_group.slash_echo.location
  resource_group_name         = azurerm_resource_group.slash_echo.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "create",
      "delete",
      "list",
      "update"
    ]

    secret_permissions = [
      "get",
      "set",
      "delete",
      "list"
    ]

    storage_permissions = [
      "get",
      "delete",
      "list",
      "set",
      "update"
    ]
  }
}

resource "azurerm_key_vault_key" "slack" {
  name         = "slack-secrets-key"
  key_vault_id = azurerm_key_vault.slash_echo.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_secret" "slack_verification_token" {
  name         = "slack-verification-token"
  value        = var.slack_verification_token
  key_vault_id = azurerm_key_vault.slash_echo.id
}
