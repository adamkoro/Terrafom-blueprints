resource "libvirt_domain" "minio" {
  name = "minio"
  cpu {
    mode = "host-passthrough"
  }
  autostart = true
  vcpu      = 2
  memory    = 1024
  machine   = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  disk {
    volume_id = libvirt_volume.root_disk.id
  }
  #disk {
  #  volume_id = libvirt_volume.swap_disk.id
  #}
  disk {
    volume_id = libvirt_volume.data_disk.id
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = libvirt_cloudinit_disk.cloud_init.id

  provisioner "local-exec" {
    command = "while ! nc -q0 ${var.node_ip_address} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.node_ip_address},' --private-key ${var.ssh_private_key_path} setup.yaml --extra-vars 'minio_admin_username=${var.minio_admin_username} minio_admin_password=${var.minio_admin_password} minio_volumes=${var.minio_volumes} minio_url=${var.server_fqdn}'"
  }
}

resource "libvirt_volume" "root_disk" {
  name   = "minio-root.qcow2"
  pool   = var.root_volume_pool
  source = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
}

#resource "libvirt_volume" "swap_disk" {
#  name = "repo-manager-swap.qcow2"
#  pool = var.swap_volume_pool
#  size = 4294967296
#}

resource "libvirt_volume" "data_disk" {
  name = "minio-data.qcow2"
  pool = var.data_volume_pool
  size = 64424509440
}

resource "libvirt_cloudinit_disk" "cloud_init" {
  pool           = var.root_volume_pool
  name           = "minio-cloud-init.iso"
  user_data      = <<EOF
#cloud-config
hostname: minio
fqdn: ${var.server_fqdn}
manage_etc_hosts: true
users:
  - name: ${var.cloud_init_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users
    home: /home/${var.cloud_init_username}
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - ${file("${var.cloud_init_sshkey}")}
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    ${var.cloud_init_username}:${var.cloud_init_password}
  expire: False
runcmd:
  - sysctl vm.swappiness=10
EOF
  network_config = <<EOF
version: 1
config:
    - type: physical
      name: eth0
      subnets:
      - type: static
        address: '${var.node_ip_address}'
        netmask: '255.255.255.0'
        gateway: '192.168.1.254'
    - type: nameserver
      address:
      - '${var.cloud_init_nameserver}'
      search:
      - '${var.cloud_init_search_domain}'
EOF
}
