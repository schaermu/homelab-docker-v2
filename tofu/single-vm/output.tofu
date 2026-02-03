output "node" {
  value = {
    name = var.host.name,
    ip   = var.host.network.ip
  }
}
