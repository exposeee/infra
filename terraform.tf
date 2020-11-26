variable "do_token" {
}

variable "ssh_fingerprint" {
}

variable "dnsimple_token" {
}

variable "dnsimple_account" {
}

variable "dnsimple_domain" {
}

provider "digitalocean" {
  token = var.do_token
}

provider "dnsimple" {
  token = "${var.dnsimple_token}"
  account = "${var.dnsimple_account}"
}

# create two droplets
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

# create two subdomains

resource "dnsimple_record" "api-subdomain" {
  depends_on = [
    digitalocean_droplet.exposeee-api,
  ]

  domain = "${var.dnsimple_domain}"
  name   = "api"
  value  = "${digitalocean_droplet.exposeee-api.ipv4_address}"
  type   = "A"
  ttl    = 3600
}

resource "dnsimple_record" "app-subdomain" {
  depends_on = [
    digitalocean_droplet.exposeee-app,
  ]

  domain = "${var.dnsimple_domain}"
  name   = "app"
  value  = "${digitalocean_droplet.exposeee-app.ipv4_address}"
  type   = "A"
  ttl    = 3600
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    dnsimple_record.api-subdomain,
    dnsimple_record.app-subdomain,
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-api.name} ansible_host=${dnsimple_record.api-subdomain.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 allowed_origin=${dnsimple_record.app-subdomain.hostname}' > api-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-app.name} ansible_host=${dnsimple_record.app-subdomain.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 api_url=${dnsimple_record.api-subdomain.hostname}' > app-inventory"
  }
}

# output the exposeee-api droplets ip
output "api-ip" {
  value = digitalocean_droplet.exposeee-api.ipv4_address
}

# output the exposeee-app droplets ip
output "app-ip" {
  value = digitalocean_droplet.exposeee-app.ipv4_address
}
