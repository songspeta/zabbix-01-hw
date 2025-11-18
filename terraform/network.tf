# Сеть
resource "yandex_vpc_network" "net" {
  name = "zabbix-net"
}

# Подсеть
resource "yandex_vpc_subnet" "subnet" {
  name           = "zabbix-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# security group
resource "yandex_vpc_security_group" "sg" {
  name       = "zabbix-sg"
  network_id = yandex_vpc_network.net.id


  ingress {
    protocol       = "TCP"
    from_port      = 1
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "UDP"
    from_port      = 1
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}