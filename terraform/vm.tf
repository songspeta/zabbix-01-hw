# Получаем образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# ВМ для Zabbix Server
resource "yandex_compute_instance" "zabbix-server" {
  name        = "zabbix-server"
  hostname    = "zabbix-server"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 4
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-ssd"
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

# ВМ для Zabbix-host
resource "yandex_compute_instance" "zabbix-host" {
  name        = "zabbix-host"
  hostname    = "zabbix-host"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "local_file" "inventory" {
  content  = <<-XYZ
[yc:children]
zabbix-server
zabbix-host

[yc:vars]
ansible_user=spet
ansible_ssh_private_key_file = ~/.ssh/id_rsa

[zabbix-server]
zabbix-server ansible_host=${yandex_compute_instance.zabbix-server.network_interface.0.nat_ip_address}
[zabbix-host]
zabbix-host ansible_host=${yandex_compute_instance.zabbix-host.network_interface.0.nat_ip_address}
  XYZ
  filename = "${path.module}/../ansible/hosts.ini"
}