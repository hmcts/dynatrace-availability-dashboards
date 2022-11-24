data "azurerm_key_vault" "dt_data_key_vault" {
  name                = var.dt_data_key_vault.name
  resource_group_name = var.dt_data_key_vault.resource_group_name
}
data "azurerm_key_vault_secret" "dt_api_token" {
  name         = var.dt_data_key_vault.secret_name
  key_vault_id = data.azurerm_key_vault.dt_data_key_vault.id
}
