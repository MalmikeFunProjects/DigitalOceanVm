locals {
  connection_user = "root"
}

variable "do_token" {
  description = "Digital Ocean personal access token"
  sensitive = true
  type = string
}

variable "pvt_key" {
  description = "SSH private key on host machine"
  sensitive = true
  type = string
}

variable "pub_key" {
  description = "SSH public key on host machine"
  sensitive = false
  type = string
}

variable "do_ssh_key_name" {
  description = "Name of ssh key store in digital ocean"
  sensitive = false
  type = string
}

variable "ubuntu_image" {
  description = "Version of ubuntu to be installed"
  type = string
}

variable "droplet_name" {
  description = "Name of droplet"
  type = string
}

variable "deployment_region" {
  description = "Region the droplet is to be created"
  type = string
}

variable "droplet_size" {
  description = "Size (Compute specifications) of the droplet"
  type = string
}
