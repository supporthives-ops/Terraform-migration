output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.main.private_ip_address
}

output "ssh_command" {
  value = "ssh -i <PATH_TO_NEW_PRIVATE_KEY> ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}
