variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_public_key" {
  type = string
}

variable "ssh_source_cidr" {
  type = string
}

variable "data_disk_size_gb" {
  type    = number
  default = 512
}

variable "enable_openvpn_ingress" {
  type    = bool
  default = false
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "tags" {
  type    = map(string)
  default = {}
}