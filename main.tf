resource "random_pet" "bonus_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "bonus" {
  location = var.resource_group_location
  name     = random_pet.bonus_name.id
}

resource "azurerm_storage_account" "bonus" {
  name                     = "bonusmaxbos"
  resource_group_name      = azurerm_resource_group.bonus.name
  location                 = azurerm_resource_group.bonus.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.bonus.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "ping_script" {
  name                   = "ping-test.sh"
  storage_account_name   = azurerm_storage_account.bonus.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "scripts/ping-test.sh"
}

resource "azurerm_virtual_network" "bonus" {
  name                = "bonus-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.bonus.location
  resource_group_name = azurerm_resource_group.bonus.name
}

resource "azurerm_subnet" "bonus" {
  name                 = "bonus-subnet"
  resource_group_name  = azurerm_resource_group.bonus.name
  virtual_network_name = azurerm_virtual_network.bonus.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "bonus" {
  count               = var.vm_count
  name                = "bonus-nic-${count.index}"
  location            = azurerm_resource_group.bonus.location
  resource_group_name = azurerm_resource_group.bonus.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bonus.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "vm_passwd" {
  count   = var.vm_count  # The number of passwords to create, one for each VM.
  length  = 16
  special = true
}

resource "azurerm_virtual_machine" "bonus" {
  count                 = var.vm_count
  name                  = "bonus-vm-${count.index}"
  location              = azurerm_resource_group.bonus.location
  resource_group_name   = azurerm_resource_group.bonus.name
  network_interface_ids = [
    azurerm_network_interface.bonus[count.index].id,
  ]
  vm_size               = "Standard_B1s"
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS" 
  }

  os_profile {
    computer_name  = "myvm${count.index}"
    admin_username = "adminuser"
    admin_password = random_password.vm_passwd[count.index].result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_network_security_group" "bonus" {
  name = "bonus-nsg"
  location = azurerm_resource_group.bonus.location
  resource_group_name   = azurerm_resource_group.bonus.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
  security_rule {
    name                       = "allow_icmp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "bonus" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.bonus[count.index].id
  network_security_group_id = azurerm_network_security_group.bonus.id
}

resource "azurerm_virtual_machine_extension" "bonus" {
  count = var.vm_count
  name = "ping-script-${count.index}"
  virtual_machine_id = azurerm_virtual_machine.bonus[count.index].id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
  {
    "script": "ping-test.sh",
    "fileUris": ["${azurerm_storage_account.bonus.primary_blob_endpoint}${azurerm_storage_container.scripts.name}/ping-test.sh"]
  }
  SETTINGS
}
