terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  alias = "digitalocean"
  token = var.do_token
}

module "run_vm_my_rides" {
  source = "./modules/vm-my-rides"
  providers = {
    digitalocean = digitalocean.digitalocean
  }
  do_token = var.do_token
  pvt_key = var.pvt_key
  pub_key = var.pub_key
  do_ssh_key_name = var.do_ssh_key_name
  ubuntu_image = var.ubuntu_image
  droplet_name = var.droplet_name
  deployment_region = var.deployment_region
  droplet_size = var.droplet_size
}

resource "local_file" "droplet_ip_address" {
    content  = module.run_vm_my_rides.droplet_ip_address
    filename = "inventory"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    # command = "ANSIBLE_HOST_KEY_CHECKING=False ansible all -i ${local_file.droplet_ip_address.filename} -u root -m apt -a 'upgrade=yes update_cache=yes cache_valid_time=86400' --private-key ${var.pvt_key} --become;"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ${module.run_vm_my_rides.droplet_ip_address}, --private-key ${var.pvt_key} -e pub_key=${var.pub_key} configure_droplet.yml"
  }
}

output "droplet_ip_address" {
  value = module.run_vm_my_rides.droplet_ip_address
  sensitive = false # set to true if the logs will be publicly available
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
  default     = "ubuntu-24-10-x64"
  type = string
}

variable "droplet_name" {
  description = "Name of droplet"
  default     = "vm-my-rides"
  sensitive = false
  type = string
}

variable "deployment_region" {
  description = "Region the droplet is to be created"
  default     = "fra1"
  type = string
}

variable "droplet_size" {
  description = "Size (Compute specifications) of the droplet"
  default     = "s-4vcpu-8gb"
  type = string
}

