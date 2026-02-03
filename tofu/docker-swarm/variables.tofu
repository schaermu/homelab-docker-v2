variable "proxmox" {
  description = "Proxmox VE configuration"
  type = object({
    cluster = string,
    node    = string,
    api_url = string,
  })
}

variable "swarm" {
  description = "Docker swarm configuration"
  type = object({
    name                  = string,
    base_vm_id            = optional(number, 100),
    datastore_id          = string,
    template_datastore_id = string,
    disk_image_id         = string
    user_data_file_id     = string

    specs = object({
      default_disk_size = number,
      storage_disk_size = number,
      manager = object({
        count         = number,
        first_hostnum = number,
        cpu           = number,
        memory        = number
      }),
      worker = object({
        count         = number,
        first_hostnum = number,
        cpu           = number,
        memory        = number
      })
    })

    network = object({
      bridge  = string,
      cidr    = string
      gateway = string,
      dns     = optional(set(string))
    })
  })
}
