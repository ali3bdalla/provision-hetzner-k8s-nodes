 resource "local_file" "ansible_public_inventory" {
  content  = templatefile("inventory.tmpl", {
    master_ips = hcloud_server.master_servers[*].ipv4_address
    worker_ips   = hcloud_server.worker_servers[*].ipv4_address
  })
  filename = "public-inventory.ini"
  depends_on = [
    hcloud_server.master_servers,
    hcloud_server.worker_servers
  ]
}

 resource "local_file" "ansible_private_inventory" {
  content  = templatefile("inventory.tmpl", {
    master_ips = [for i in range(1,var.master_server_count + 1) : "10.0.1.${i}"]
    worker_ips   = [for i in range(1,var.worker_server_count + 1) : "10.0.2.${i}"]
  })
  filename = "private-inventory.ini"
  depends_on = [
    hcloud_server.master_servers,
    hcloud_server.worker_servers
  ]
}