terraform {
  required_version = ">= 0.12"
  experiments = [variable_validation]
}

# Provider configuration. Typically there will only be one provider config, unless working with multi account and / or multi region resources
provider "azurerm" {
  version = "=2.3.0"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}