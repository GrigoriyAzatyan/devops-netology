# Создаем VPC
resource "yandex_vpc_network" "netology" {
  name = "netology"
}

# Подсеть 1
resource "yandex_vpc_subnet" "subnet_01" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.netology.id}"
}

# Подсеть 2
resource "yandex_vpc_subnet" "subnet_02" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.netology.id}"
}


