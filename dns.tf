resource "hcloud_rdns" "worker_dns" {
  load_balancer_id = hcloud_load_balancer.worker_load_balancer.id
  ip_address = hcloud_load_balancer.worker_load_balancer.ipv4
  dns_ptr    = "example.com"
  depends_on = [
    hcloud_load_balancer.worker_load_balancer
  ]
}
