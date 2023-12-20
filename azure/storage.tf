resource "azurerm_storage_account" "slash_echo" {
  name                     = "slashechodemo"
  resource_group_name      = azurerm_resource_group.slash_echo.name
  location                 = azurerm_resource_group.slash_echo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "slash_echo" {
  name                  = "slash-echo-sc"
  storage_account_name  = azurerm_storage_account.slash_echo.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "slash_echo" {
  name = format("slash-echo-%s", filebase64sha256("slash-echo.zip"))
  storage_account_name   = azurerm_storage_account.slash_echo.name
  storage_container_name = azurerm_storage_container.slash_echo.name
  type   = "Block"
  source = "slash-echo.zip"
}

data "azurerm_storage_account_sas" "slash_echo" {
  connection_string = azurerm_storage_account.slash_echo.primary_connection_string
  https_only        = false
  resource_types {
    service   = false
    container = false
    object    = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start  = "2020-03-30"
  expiry = "2028-03-21"
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}