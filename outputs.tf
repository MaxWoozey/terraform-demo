
output "resource_group_name" {
  value = azurerm_resource_group.bonus.name
}

output "admin_password" {
  value = random_password.vm_passwd[*].result
  sensitive = true
}

output "vm_private_ips" {
  value = [
    for vm in azurerm_virtual_machine.bonus : vm.network_interface_ids[0]
  ]
  description = "The private IP addresses of the VMs."
}

output "aggregated_ping_results" {
  description = "Aggregated ping results from all VMs"
  value = {
    for result in data.azurerm_storage_blob.ping_results : 
    result.name => result.content
  }
}
