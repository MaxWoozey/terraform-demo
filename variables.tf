variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "bonus"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "vm_count" {
  type        = number
  default     = 4
  description = "The number of virtual machines to create."
}

variable "vm_flavor" {
  description = "Flavor for virtual machines"
  type        = string
  default     = "Standard_B1s"  # Example for Azure
}

variable "vm_image" {
  description = "Virtual machine image"
  type        = string
  default     = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
}
