data "proxmox_virtual_environment_file" "debian_iso" {
  node_name    = var.proxmox.node
  datastore_id = var.swarm.template_datastore_id
  content_type = "iso"
  file_name    = var.swarm.image_name
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  node_name    = var.proxmox.node
  datastore_id = var.swarm.template_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "user-data-cloud-config.yaml"
    data      = <<-EOF
      #cloud-config
      timezone: Europe/Zurich
      users: 
      - default
      - name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups:
        - sudo
        - docker
        home: /home/ansible
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
