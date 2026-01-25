data "proxmox_virtual_environment_file" "debian_iso" {
  node_name    = var.proxmox_node
  datastore_id = var.template_datastore_id
  content_type = "iso"
  file_name    = "debian-13-genericcloud-amd64-shrink.img"
}
