variable "worker_server_count" {
  description = "Number of servers to create"
  default     = 3
}
variable "hcloud_worker_server_type" {
  description = "worker server node type"
}
variable "worker_os" {
  description = "worker server node type"
}

resource "hcloud_load_balancer" "worker_load_balancer" {
  name               = "worker_load_balancer"
  load_balancer_type = "lb11"
  location           = "nbg1"
}
resource "hcloud_load_balancer_network" "worker_load_balancer_network" {
  load_balancer_id = hcloud_load_balancer.worker_load_balancer.id
  network_id       = data.hcloud_network.cluster_network.id
  ip               = "10.0.2.50"
}
resource "hcloud_load_balancer_target" "worker_load_balancer_target" {
  type             = "label_selector"
  use_private_ip = "true"
  load_balancer_id = hcloud_load_balancer.worker_load_balancer.id
  label_selector = "node=worker"
}
resource "hcloud_load_balancer_service" "worker_load_balancer_80_service" {
    load_balancer_id = hcloud_load_balancer.worker_load_balancer.id
    protocol         = "tcp"
    listen_port = "80"
    destination_port = "80"
}

resource "hcloud_load_balancer_service" "worker_load_balancer_443_service" {
    load_balancer_id = hcloud_load_balancer.worker_load_balancer.id
    protocol         = "tcp"
    listen_port = "443"
    destination_port = "443"
}
resource "hcloud_firewall" "worker_firewall" {
  name = "worker_firewall"
  # rule {
  #   direction = "in"
  #   protocol  = "tcp"
  #   port = "6443"
  #   source_ips = [
  #     "10.0.0.0/16"
  #   ]
  # }

}

resource "hcloud_server" "worker_servers" {
  count = var.worker_server_count
  name        = "worker-${count.index + 1}"
  image       = var.worker_os
  server_type = var.hcloud_worker_server_type
  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]
  firewall_ids = [
    hcloud_firewall.worker_firewall.id
  ]

  labels = {
    "server" : "worker-${count.index + 1}",
    "node": "worker"
  }
  location = element(["nbg1", "fsn1", "hel1"], count.index % 3)
  network {
    network_id = data.hcloud_network.cluster_network.id
    ip         = "10.0.2.${count.index + 1}"
    alias_ips  = [
    ]
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.worker,
    hcloud_ssh_key.ssh_key
  ]
}


output "worker_ips" {
  value = hcloud_server.worker_servers[*].ipv4_address
}