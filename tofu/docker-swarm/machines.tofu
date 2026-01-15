resource "proxmox_virtual_environment_vm" "swarm_hosts" {
  for_each = local.machines

  vm_id         = each.value.vm_id
  name          = each.value.hostname
  node_name     = var.proxmox.node
  description   = "Docker Swarm Manager Node ${each.value.hostname}"
  tags          = each.value.tags
  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge = var.swarm.network.bridge
  }

  disk {
    datastore_id = var.swarm.datastore_id
    interface    = "scsi0"
    size         = 50
    file_format  = "raw"
    file_id      = data.proxmox_virtual_environment_file.debian_iso.id
    cache        = "writeback"
    iothread     = false
    ssd          = true
    discard      = "on"
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  dynamic "hostpci" {
    for_each = each.value.has_igpu ? [1] : []
    content {
      # Passthrough iGPU
      device  = "hostpci0"
      mapping = "igpu"
      pcie    = true
      rombar  = true
      xvga    = false
    }
  }

  initialization {
    datastore_id      = var.swarm.template_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.swarm.network.gateway
      }
    }
  }
}
