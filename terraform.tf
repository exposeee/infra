variable "do_token" {
}

variable "ssh_fingerprint" {
}

provider "digitalocean" {
  token = var.do_token
}

# create two demo droplets
resource "digitalocean_droplet" "exposeee-api" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-api"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-app" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-app"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-app" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-app"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    digitalocean_droplet.exposeee-api,
    digitalocean_droplet.exposeee-app,
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-api.name} ansible_host=${digitalocean_droplet.exposeee-api.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 allowed_origin=${digitalocean_droplet.exposeee-app.ipv4_address}' > api-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-app.name} ansible_host=${digitalocean_droplet.exposeee-app.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 api_url=${digitalocean_droplet.exposeee-api.ipv4_address}' > app-inventory"
  }
}

# output the exposeee-api droplets ip
output "api-ip" {
  value = digitalocean_droplet.exposeee-api.ipv4_address
}

# output the exposeee-app droplets ip
output "app-ip" {
  value = digitalocean_droplet.exposeee-api.ipv4_address
}
