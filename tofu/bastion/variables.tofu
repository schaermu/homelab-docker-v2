variable "proxmox" {
  description = "Proxmox VE configuration"
  type = object({
    cluster = string,
    node    = string,
    api_url = string,
  })
}

variable "bastion" {
  description = "Bastion host configuration"
  type = object({
    name                  = string,
    vm_id                 = optional(number, 100),
    datastore_id          = string,
    template_datastore_id = string,
    disk_image_id         = string
    user_data_file_id     = string
    tags                  = optional(list(string), [])

    specs = object({
      cpu       = number,
      memory    = number
      disk_size = number
    })

    network = object({
      bridge  = string,
      ip      = string
      gateway = string,
      dns     = optional(set(string))
    })
  })
}
