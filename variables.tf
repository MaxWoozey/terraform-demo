variable "resource_group_location" {
  type        = string
  default     = "swedencentral"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "bonus"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "vm_count" {
  type        = number
  default     = 3
  description = "The number of virtual machines to create."
}

variable "azure_storage_account_key" {
  description = "The access key for the Azure Storage Account"
  type        = string
  sensitive   = true
}
