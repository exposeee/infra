terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    dnsimple = {
      source = "terraform-providers/dnsimple"
    }
  }
  required_version = ">= 0.13"
}
