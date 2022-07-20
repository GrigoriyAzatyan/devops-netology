# Создаем VPC
resource "yandex_vpc_network" "public" {
  name = "public"
}

# Создаем публичную подсеть
resource "yandex_vpc_subnet" "public-subnet" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.public.id}"
}

# NAT-инстанс
resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    ip_address = "192.168.10.254"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "external_ip_address_nat-instance" {
  value = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
}


