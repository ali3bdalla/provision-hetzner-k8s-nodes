# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_network" {
    type = number
}
variable "hcloud_zone" {
}

data "hcloud_network" "cluster_network" {
  id = var.hcloud_network
}

resource "hcloud_network_subnet" "master" {
  network_id   = data.hcloud_network.cluster_network.id
  type         = "cloud"
  network_zone = var.hcloud_zone
  ip_range     = "10.0.1.0/24"
}


resource "hcloud_network_subnet" "worker" {
  network_id   = data.hcloud_network.cluster_network.id
  type         = "cloud"
  network_zone = var.hcloud_zone
  ip_range     = "10.0.2.0/24"
}
