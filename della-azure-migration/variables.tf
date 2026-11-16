variable "subscription_id" {
  description = "Azure subscription ID. Do not put credentials in this project."
  type        = string
}

variable "location" {
  description = "Azure region. West India is the proposed starting point; verify SKU availability."
  type        = string
  default     = "westindia"
}

variable "resource_group_name" {
  type    = string
  default = "rg-della-migration"
}

variable "vm_name" {
  type    = string
  default = "della-staging-azure"
}

variable "vm_size" {
  description = "Initial 4 vCPU / 16 GiB candidate. Confirm availability and benchmark before production."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "Contents of the NEW Azure SSH public key (.pub), never the private key."
  type        = string
  sensitive   = true
}

variable "ssh_source_cidr" {
  description = "Your trusted public IP in CIDR notation, e.g. 203.0.113.10/32. Do not use 0.0.0.0/0."
  type        = string
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.40.0.0/16"]
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.40.1.0/24"]
}

variable "data_disk_size_gb" {
  description = "Separate application/data disk. Validate actual source filesystem layout and required capacity."
  type        = number
  default     = 512
}

variable "enable_openvpn_ingress" {
  description = "Keep false until OpenVPN topology, client ports and access policy are confirmed."
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "della"
    environment = "staging"
    managed_by  = "terraform"
    migration   = "aws-to-azure"
  }
}
