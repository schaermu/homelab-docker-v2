# Prepare Proxmox

1. Run default installation of Proxmox VE 9.x.
2. Login as root, create cluster `galaxy`
3. Deactivate enterprise repositories (arthur -> Updates -> Repositiories) and activate `pve-no-subscription` instead.
4. Create new LVM disk for VM's named `local-vms` (galaxy -> Storage -> Add)
5. Create new Directory for Bootstrap configuration enabled for ISO's, Snippets and Container templates called`local-bootstrap` (galaxy -> Storage -> Add)
6. Define new PCIe Passthrough device for Iris XE integrated GPU named `igpu` (galaxy -> Resource Mappings -> Add)
7. Connect to host using SSH (root@<IP>)
8. Install `sudo` (`apt get update && apt get install sudo`)
9. Create new PVE user for OpenTofu based provisioning:
   ```bash
   $ pveum user add terraform@pve
   $ pveum role add Terraform -privs "Mapping.Use, VM.Config.Network, Sys.PowerMgmt, VM.Snapshot, User.Modify, VM.Audit, Sys.Incoming, Permissions.Modify, VM.Snapshot.Rollback, Sys.Console, Pool.Allocate, VM.Backup, VM.PowerMgmt, Datastore.Audit, Sys.AccessNetwork, Mapping.Modify, Group.Allocate, Datastore.Allocate, SDN.Audit, Sys.Audit, VM.Allocate, VM.Console, Sys.Syslog, Pool.Audit, Realm.Allocate, Datastore.AllocateTemplate, SDN.Use, VM.Config.CDROM, VM.Config.Disk, VM.Config.Cloudinit, VM.Config.Memory, VM.Config.HWType, Datastore.AllocateSpace, VM.Clone, Realm.AllocateUser, Mapping.Audit, Sys.Modify, SDN.Allocate, VM.Migrate, VM.Config.Options, VM.GuestAgent.Unrestricted, VM.Config.CPU, VM.GuestAgent.Audit"
   $ pveum aclmod / -user terraform@pve -role Terraform
   $ pveum user token add terraform@pve provider --privsep=0
   ```
10. Add token to `.env.local` as variable `TF_VAR_proxmox_api_token`.
11. Create newlinux user for terraform provider `useradd -m terraform`
12. Grant sudoers privileges: `visudo -f /etc/sudoers.d/terraform`:
    ```terraform ALL=(root) NOPASSWD: /sbin/pvesm
    terraform ALL=(root) NOPASSWD: /sbin/qm
    terraform ALL=(root) NOPASSWD: /usr/bin/tee /var/lib/vz/*
    terraform ALL=(root) NOPASSWD: /usr/bin/tee /var/lib/bootstrap/*
    terraform ALL=(root) NOPASSWD: /usr/bin/whoami
    ```
13. Generate new SSH key on your local machine (`ssh-keygen -t ed25519 -C "terraform@pve"`) and copy the generated public key to `/home/terraform/.ssh/authorized_keys` on the Proxmox host.

# Prepare Base image

1. On your local machine, follow these steps:

```
$ sudo apt install libguestfs-tools
$ wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
$ virt-customize -a debian-13-genericcloud-amd64.qcow2 --install qemu-guest-agent,curl,wget,vim,rsync,htop
$ qemu-img convert -O qcow2 -c -o preallocation=off debian-13-genericcloud-amd64.qcow2 debian-13-genericcloud-amd64-shrink.qcow2
```

2. Upload this image to a Snippet-compatible datastore on Proxmox (you need to change the file extension to `.img`).
3. Configure both `swarm.template_datastore_id` and `swarm.image_name` in `main.tofu` accordingly.

# Deploy infrastructure

## Prepare environment

1. Run `mise i`.
2. Run `cp .env .env.local` and configure values accordingly.

## Deploy machines

1. Run `mise tofu apply` and confirm.

## Configure machines

1. Run `mise run-playbook setup_docker_swarm` to configure docker hosts for swarm mode.

# Maintenance

## Import Pocket ID seed database

1. Copy pocketid-seed.zip to swarm node currently running pocket-id_app workload
2. Run `cat ./pocketid-seed.zip | docker compose run pocket-id ./pocket-id import --yes --path -`
