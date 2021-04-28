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
  token = var.dnsimple_token
  account = var.dnsimple_account
}

# create three droplets
resource "digitalocean_droplet" "exposeee-db-qa" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-db-qa"
  region   = "fra1"
  size     = "s-4vcpu-8gb-intel"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-api-qa" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-api-qa"
  region   = "fra1"
  size     = "g-2vcpu-8gb"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-app-qa" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-app-qa"
  region   = "fra1"
  size     = "s-1vcpu-1gb-intel"
  ssh_keys = [var.ssh_fingerprint]
}

# create three subdomains

resource "dnsimple_record" "db-subdomain-qa" {
  depends_on = [
    digitalocean_droplet.exposeee-db-qa,
  ]

  domain = var.dnsimple_domain
  name   = "db-qa"
  value  = digitalocean_droplet.exposeee-db-qa.ipv4_address
  type   = "A"
  ttl    = 3600
}

resource "dnsimple_record" "api-subdomain-qa" {
  depends_on = [
    digitalocean_droplet.exposeee-api-qa,
  ]

  domain = var.dnsimple_domain
  name   = "api-qa"
  value  = digitalocean_droplet.exposeee-api-qa.ipv4_address
  type   = "A"
  ttl    = 3600
}

resource "dnsimple_record" "app-subdomain-qa" {
  depends_on = [
    digitalocean_droplet.exposeee-app-qa,
  ]

  domain = var.dnsimple_domain
  name   = "app-qa"
  value  = digitalocean_droplet.exposeee-app-qa.ipv4_address
  type   = "A"
  ttl    = 3600
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    dnsimple_record.db-subdomain-qa,
    dnsimple_record.api-subdomain-qa,
    dnsimple_record.app-subdomain-qa,
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-db-qa.name} ansible_host=${dnsimple_record.db-subdomain-qa.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 database_password=123' > inventories/db-qa-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-api-qa.name} ansible_host=${dnsimple_record.api-subdomain-qa.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 allowed_origin=${dnsimple_record.app-subdomain-qa.hostname}' > inventories/api-qa-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-app-qa.name} ansible_host=${dnsimple_record.app-subdomain-qa.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 api_url=${dnsimple_record.api-subdomain-qa.hostname}' > inventories/app-qa-inventory"
  }
}

# output the exposeee-api droplets ip
output "db-qa-ip" {
  value = digitalocean_droplet.exposeee-db-qa.ipv4_address
}

# output the exposeee-api droplets ip
output "api-qa-ip" {
  value = digitalocean_droplet.exposeee-api-qa.ipv4_address
}

# output the exposeee-app droplets ip
output "app-qa-ip" {
  value = digitalocean_droplet.exposeee-app-qa.ipv4_address
}
