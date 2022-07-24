# Создаем VPC
resource "yandex_vpc_network" "public" {
  name = "public"
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public-subnet" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.public.id}"
  route_table_id = "${yandex_vpc_route_table.to-private-route.id}"
}

# Статический маршрут из публичной подсети в приватную

resource "yandex_vpc_route_table" "to-private-route" {
  network_id = "${yandex_vpc_network.public.id}"

  static_route {
    destination_prefix = "192.168.20.0/24"
    next_hop_address   = "192.168.10.254"
  }
}

# Приватная подсеть

resource "yandex_vpc_network" "private" {
  name = "private"
}

resource "yandex_vpc_subnet" "private-subnet" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.private.id}"
  route_table_id = "${yandex_vpc_route_table.nat-route.id}"
}

# Статический маршрут из приватной подсети во все остальные

resource "yandex_vpc_route_table" "nat-route" {
  network_id = "${yandex_vpc_network.private.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.20.254"
  }
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
  
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    ip_address = "192.168.20.254"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "external_ip_address_nat-instance" {
  value = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
}
# Публичная ВМ

resource "yandex_compute_instance" "public-instance" {
  name = "public-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd826dalmbcl81eo5nig"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "external_ip_address_public-instance" {
  value = yandex_compute_instance.public-instance.network_interface.0.nat_ip_address
}


# Виртуалка с внутренним IP

resource "yandex_compute_instance" "private-instance" {
  name = "private-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd826dalmbcl81eo5nig"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "external_ip_address_private-instance" {
  value = yandex_compute_instance.private-instance.network_interface.0.ip_address
}

