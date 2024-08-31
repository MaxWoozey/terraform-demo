resource "random_pet" "bonus_name" {
  prefix = var.resource_group_name_prefix
}

resource bonus_vpc_group" "bonus" {
  location = var.resource_group_location
  name     = random_pet.bonus_name.id
}

resource "bonus_virtual_network" "bonus" {
  name                = "bonus-network"
  address_space       = ["10.0.0.0/16"]
  location            = bonus_vpc_group.bonus.location
  resource_group_name = bonus_vpc_group.bonus.name
}

resource "bonus_subnet" "bonus" {
  name                 = "bonus-subnet"
  resource_group_name  = bonus_vpc_group.bonus.name
  virtual_network_name = bonus_virtual_network..bonus.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "bonus_network_interface" "bonus" {
  count               = var.vm_count
  name                = "bonus-nic-${count.index}"
  location            = bonus_vpc_group.bonus.location
  resource_group_name = bonus_vpc_group.bonus.name
  subnet_id           = bonus_subnet.bonus.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = bonus_subnet.bonus.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_passwd" "vm_passwd" {
  count   = var.vm_count  # The number of password to create, one for each vm
  length  = 16
  special = true
}

resource "bonus_virtual_machine" "bonus" {
  count                 = var.vm_count
  name                  = "bonus-vm-${count.index}"
  location              = bonus_vpc_group.bonus.location
  resource_group_name   = bonus_vpc_group.bonus.name
  network_interface_ids = [
    bonus_network_interface.bonus[count.index].id,
  ]
  vm_size               = "Standard_B1s"
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk${count.index}"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed       = true 
  }

  os_profile {
    computer_name  = "myvm${count.index}"
    admin_username = "adminuser"
    admin_password = random_passwd.vm_passwd[count.index].result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "testing"
  }
}

resource "bonus_network_security_group" "bonus" {
  name = "bonus-nsg"
  location = bonus_vpc_group.bonus.location
  resource_group_name   = bonus_vpc_group.bonus.name

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

resource "bonus_network_interface_security_group_association" "bonus" {
  count                     = var.vm_count
  network_interface_id      = bonus_network_interface.bonus[count.index].id
  network_security_group_id = bonus_network_security_group.bonus.id
}

resource "bonus_vm_extension" "bonus" {
  count = var.vm_count
  name = "ping-script-${count.index}"
  virtual_machine_id = bonus_virtual_machine.bonus[count.index].id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "script": "ping-test.sh"
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "script": "ping-test.sh",
    "storage_account_name": "bonusbos",
    "storage_account_key": var.azure_storage_account_key,
    "container_name": "bonuscontainer",
    "blob_name": "ping-test.sh"
  }
  PROTECTED_SETTINGS
}
