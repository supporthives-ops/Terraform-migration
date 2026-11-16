variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "westindia"
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "Terraform-testserver"
}

variable "vm_name" {
  description = "Linux virtual machine name"
  type        = string
  default     = "della-staging-azure"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  description = "Linux VM administrator username"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

variable "ssh_source_cidr" {
  description = "Public IP CIDR allowed to connect through SSH"
  type        = string
}

variable "data_disk_size_gb" {
  description = "Managed data disk size in GB"
  type        = number
  default     = 512
}

variable "enable_openvpn_ingress" {
  description = "Whether to allow OpenVPN inbound traffic"
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Application subnet address prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "tags" {
  description = "Tags applied to Azure resources"
  type        = map(string)
  default     = {
    project     = "della-azure-migration"
    environment = "staging"
    managed_by  = "terraform"
  }
}