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
resource "digitalocean_droplet" "exposeee-db-prod" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-db-prod"
  region   = "fra1"
  size     = "s-4vcpu-8gb-intel"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-api-prod" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-api-prod"
  region   = "fra1"
  size     = "g-2vcpu-8gb"
  ssh_keys = [var.ssh_fingerprint]
}

resource "digitalocean_droplet" "exposeee-app-prod" {
  image    = "ubuntu-20-04-x64"
  name     = "exposeee-app-prod"
  region   = "fra1"
  size     = "s-1vcpu-1gb-intel"
  ssh_keys = [var.ssh_fingerprint]
}

# create three subdomains

resource "dnsimple_record" "db-subdomain-prod" {
  depends_on = [
    digitalocean_droplet.exposeee-db-prod,
  ]

  domain = var.dnsimple_domain
  name   = "db"
  value  = digitalocean_droplet.exposeee-db-prod.ipv4_address
  type   = "A"
  ttl    = 3600
}

resource "dnsimple_record" "api-subdomain-prod" {
  depends_on = [
    digitalocean_droplet.exposeee-api-prod,
  ]

  domain = var.dnsimple_domain
  name   = "api"
  value  = digitalocean_droplet.exposeee-api-prod.ipv4_address
  type   = "A"
  ttl    = 3600
}

resource "dnsimple_record" "app-subdomain-prod" {
  depends_on = [
    digitalocean_droplet.exposeee-app-prod,
  ]

  domain = var.dnsimple_domain
  name   = "app"
  value  = digitalocean_droplet.exposeee-app-prod.ipv4_address
  type   = "A"
  ttl    = 3600
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    dnsimple_record.db-subdomain-prod,
    dnsimple_record.api-subdomain-prod,
    dnsimple_record.app-subdomain-prod,
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-db-prod.name} ansible_host=${dnsimple_record.db-subdomain-prod.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 database_password=123' > inventories/db-prod-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-api-prod.name} ansible_host=${dnsimple_record.api-subdomain-prod.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 allowed_origin=${dnsimple_record.app-subdomain-prod.hostname}' > inventories/api-prod-inventory"
  }

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.exposeee-app-prod.name} ansible_host=${dnsimple_record.app-subdomain-prod.hostname} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 api_url=${dnsimple_record.api-subdomain-prod.hostname}' > inventories/app-prod-inventory"
  }
}

# output the exposeee-api droplets ip
output "db-prod-ip" {
  value = digitalocean_droplet.exposeee-db-prod.ipv4_address
}

# output the exposeee-api droplets ip
output "api-prod-ip" {
  value = digitalocean_droplet.exposeee-api-prod.ipv4_address
}

# output the exposeee-app droplets ip
output "app-prod-ip" {
  value = digitalocean_droplet.exposeee-app-prod.ipv4_address
}
