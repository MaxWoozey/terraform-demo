output "resource_group_name" {
  value = azurerm_resource_group.bonus.name
}

output "admin_password" {
  value = random_password.vm_passwd[*].result
  sensitive = true
}
