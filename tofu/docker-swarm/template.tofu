resource "proxmox_virtual_environment_download_file" "debian_iso" {
  content_type       = "iso"
  node_name          = var.proxmox.node
  datastore_id       = "local-bootstrap"
  url                = var.swarm.image.url
  file_name          = "debian-${var.swarm.image.version}.img"
  checksum           = var.swarm.image.checksum
  checksum_algorithm = var.swarm.image.checksum_type
  overwrite          = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  node_name    = var.proxmox.node
  datastore_id = "local-bootstrap"
  content_type = "snippets"

  source_raw {
    file_name = "user-data-cloud-config.yaml"
    data      = <<-EOF
      #cloud-config
      timezone: Europe/Zurich
      users:
      - default
      - name: schaermu
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups:
        - sudo
        home: /home/schaermu
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh-authorized-keys:
        %{for key in var.swarm.management.ssh_public_keys}
        - ${key}
        %{endfor}
      ssh_pwauth: false
      package_update: true
      packages:
      - qemu-guest-agent
      runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      EOF
  }
}

resource "proxmox_virtual_environment_vm" "vm_template" {
  depends_on = [proxmox_virtual_environment_download_file.debian_iso]

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_file.user_data_cloud_config.id]
  }

  node_name     = var.proxmox.node
  vm_id         = 9000
  name          = "debian-13-cloudinit-template"
  description   = "Debian 13 VM Template with Cloud-Init"
  bios          = "seabios"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  started       = false
  template      = true

  agent {
    enabled = true
  }

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    file_id      = proxmox_virtual_environment_download_file.debian_iso.id
    datastore_id = "local-bootstrap"
    interface    = "scsi0"
    size         = 8
    file_format  = "raw"
    cache        = "writeback"
    iothread     = false
    ssd          = true
    discard      = "on"
  }

  network_device {
    bridge = var.swarm.network.bridge
  }

  # cloud-init config
  initialization {
    datastore_id      = "local-bootstrap"
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
}
