terraform {
  # backend "s3" {
  #   bucket = "mybucket"
  #   key    = "path/to/my/key"
  #   region = "us-east-1"
  # }
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.42.1"
    }
  }
}

variable "hcloud_token" {
  sensitive = true
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "cluster-ssh-Key"
  public_key = file("~/.ssh/id_rsa.pub")
}
provider "hcloud" {
  token = var.hcloud_token
}
