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
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
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
