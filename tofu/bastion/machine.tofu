resource "proxmox_virtual_environment_vm" "bastion_host" {
  vm_id         = var.bastion.vm_id
  name          = var.bastion.name
  node_name     = var.proxmox.node
  description   = "Bastion host ${var.bastion.name}"
  tags          = var.bastion.tags
  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  cpu {
    cores = var.bastion.specs.cpu
    type  = "host"
  }

  memory {
    dedicated = var.bastion.specs.memory
  }

  network_device {
    bridge = var.bastion.network.bridge
  }

  disk {
    datastore_id = var.bastion.datastore_id
    interface    = "scsi0"
    size         = var.bastion.specs.disk_size
    file_format  = "raw"
    file_id      = var.bastion.disk_image_id
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
    datastore_id      = var.bastion.template_datastore_id
    user_data_file_id = var.bastion.user_data_file_id

    ip_config {
      ipv4 {
        address = "${var.bastion.network.ip}/24"
        gateway = var.bastion.network.gateway
      }
    }
  }
}
