variable "do_token" {
  description = "Digital Ocean personal access token"
  sensitive = true
}

variable "pvt_key" {
  description = "SSH private key on host machine"
  sensitive = true
}

variable "pub_key" {
  description = "SSH public key on host machine"
  sensitive = true
}

variable "do_ssh_key_name" {
  description = "Name of ssh key store in digital ocean"
  sensitive = true
}

variable "ubuntu_image" {
  description = "Version of ubuntu to be installed"
  default     = "ubuntu-24-10-x64"
}

variable "droplet_name" {
  description = "Name of droplet"
  default     = "vm-my-rides"
  sensitive = true
}

variable "deployment_region" {
  description = "Region the droplet is to be created"
  default     = "fra1"
}

variable "droplet_size" {
  description = "Size (Compute specifications) of the droplet"
  default     = "s-4vcpu-8gb"
}

variable "connection_user" {
  description = "User connecting to droplet"
  default     = "root"
}
