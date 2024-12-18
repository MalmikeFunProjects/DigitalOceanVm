resource "digitalocean_droplet" "vm-my-rides" {
  image  = var.ubuntu_image
  name   = var.droplet_name
  region = var.deployment_region
  size   = var.droplet_size
  ssh_keys = [
    data.digitalocean_ssh_key.ssh_key_name.id
  ]

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt update",
      "echo DONE!"
    ]

    connection {
      host        = self.ipv4_address
      user        = var.connection_user
      type        = "ssh"
      private_key = file(var.pvt_key)
      timeout     = "2m"
      agent       = false
      # agent_identity = "malmike"
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' docker-install.yml"
  }
}



