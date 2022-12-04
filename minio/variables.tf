variable "cloud_init_username" {
  type = string
}

variable "cloud_init_password" {
  type = string
}

variable "cloud_init_sshkey" {
  type = string
}

variable "cloud_init_nameserver" {
  type = string
}

variable "cloud_init_search_domain" {
  type = string
}

variable "root_volume_pool" {
  type = string
}

#variable "swap_volume_pool" {
#  type = string
#}

variable "data_volume_pool" {
  type = string
}

variable "node_ip_address" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "minio_admin_username" {
  type = string
}

variable "minio_admin_password" {
  type = string
}

variable "minio_volumes" {
  type = string
}

