variable "master_server_count" {
  description = "Number of servers to create"
  default     = 3
}
variable "hcloud_master_server_type" {
  description = "master server node type"
}
variable "master_os" {
  description = "master server node type"
}


resource "hcloud_load_balancer" "master_load_balancer" {
  name               = "master_load_balancer"
  load_balancer_type = "lb11"
  location           = "nbg1"
}
resource "hcloud_load_balancer_target" "master_load_balancer_target" {
  type             = "label_selector"
  use_private_ip = "true"
  load_balancer_id = hcloud_load_balancer.master_load_balancer.id
  label_selector = "node=master"
  depends_on = [
    hcloud_load_balancer.master_load_balancer,
    hcloud_load_balancer_network.master_load_balancer_network,
  ]
}
resource "hcloud_load_balancer_network" "master_load_balancer_network" {
  load_balancer_id = hcloud_load_balancer.master_load_balancer.id
  network_id       = data.hcloud_network.cluster_network.id
  ip               = "10.0.1.50"
}

resource "hcloud_load_balancer_service" "master_load_balancer_service" {
    load_balancer_id = hcloud_load_balancer.master_load_balancer.id
    protocol         = "tcp"
    listen_port = "6443"
    destination_port = "6443"
    depends_on = [
      hcloud_load_balancer.master_load_balancer,
      hcloud_load_balancer_network.master_load_balancer_network,
    ]
}

resource "hcloud_firewall" "master_firewall" {
  name = "master_firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port = "6443"
    source_ips = [
      "10.0.0.0/16"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port = "22"
    source_ips = [
      "10.0.0.0/16"
    ]
  }


  rule {
    direction = "in"
    protocol  = "udp"
    port = "9345"
    source_ips = [
      "10.0.0.0/16"
    ]
  }

}

resource "hcloud_server" "master_servers" {
  count = var.master_server_count
  name        = "master-${count.index + 1}"
  image       = var.master_os
  server_type = var.hcloud_master_server_type
  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]
  firewall_ids = [
    hcloud_firewall.master_firewall.id
  ]

  labels = {
    "server" : "master-${count.index + 1}",
    "node": "master"
  }
  location = element(["nbg1", "fsn1", "hel1"], count.index % 3)
  network {
    network_id = data.hcloud_network.cluster_network.id
    ip         = "10.0.1.${count.index + 1}"
    alias_ips  = [
    ]
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.master,
    hcloud_ssh_key.ssh_key
  ]
}


output "master_ips" {
  value = hcloud_server.master_servers[*].ipv4_address
}
