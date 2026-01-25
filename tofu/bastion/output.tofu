output "node" {
  value = {
    name = var.bastion.name,
    ip   = var.bastion.network.ip
  }
}
