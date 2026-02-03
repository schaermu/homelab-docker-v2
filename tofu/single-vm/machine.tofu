resource "proxmox_virtual_environment_vm" "single_host" {
  vm_id         = var.host.vm_id
  name          = var.host.name
  node_name     = var.proxmox.node
  description   = var.host.name
  tags          = var.host.tags
  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  cpu {
    cores = var.host.specs.cpu
    type  = "host"
  }

  memory {
    dedicated = var.host.specs.memory
  }

  network_device {
    bridge = var.host.network.bridge
  }

  disk {
    datastore_id = var.host.datastore_id
    interface    = "scsi0"
    size         = var.host.specs.disk_size
    file_format  = "raw"
    file_id      = var.host.disk_image_id
    cache        = "writeback"
    iothread     = false
    ssd          = true
    discard      = "on"
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id      = var.host.template_datastore_id
    user_data_file_id = var.host.user_data_file_id

    ip_config {
      ipv4 {
        address = "${var.host.network.ip}/24"
        gateway = var.host.network.gateway
      }
    }
  }
}
