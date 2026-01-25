resource "proxmox_virtual_environment_file" "user_data_base_cloud_config" {
  node_name    = var.proxmox_node
  datastore_id = var.template_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "user-data-base-cloud-config.yaml"
    data      = <<-EOF
      #cloud-config
      timezone: Europe/Zurich
      users: 
      - default
      - name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups:
        - sudo
        home: /home/ansible
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh-authorized-keys:
        %{for key in [data.bitwarden_item_ssh_key.donnerchuebu.public_key, data.bitwarden_item_ssh_key.klappchuebu.public_key]}
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
