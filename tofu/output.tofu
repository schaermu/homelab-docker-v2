locals {
  managers = [for k, v in module.docker_swarm.nodes : merge(v, { name = k }) if contains(v.tags, "manager")]
  workers  = [for k, v in module.docker_swarm.nodes : merge(v, { name = k }) if contains(v.tags, "worker")]
  bastion  = module.bastion.node

  inventory_content = templatefile("${path.module}/templates/ansible_hosts.tpl", {
    managers = local.managers
    workers  = local.workers,
    bastion  = local.bastion
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory_content
  filename = "${path.root}/../ansible/inventory/hosts.ini"
}
