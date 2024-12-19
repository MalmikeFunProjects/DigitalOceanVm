terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

data "digitalocean_ssh_key" "ssh_key_name" {
  name = var.do_ssh_key_name
}


