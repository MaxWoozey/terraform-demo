
output "resource_group_name" {
  value = azurerm_resource_group.bonus.name
}

output "admin_password" {
  value = random_password.vm_passwd[*].result
  sensitive = true
}

output "sas" {
  value = data.azurerm_storage_account_blob_container_sas.results_sas.sas
  sensitive = true
}

output "aggregated_ping_results_url" {
  description = "URL of the aggregated ping results blob"
  value = "https://${azurerm_storage_account.bonus.name}.blob.core.windows.net/${azurerm_storage_container.results.name}/aggregated_ping_results.txt"
  sensitive = true
}
