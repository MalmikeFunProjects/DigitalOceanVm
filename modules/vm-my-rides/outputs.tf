output "droplet_ip_address" {
  value     = digitalocean_droplet.vm-my-rides.ipv4_address
  sensitive = false # set to true if the logs will be publicly available
}
