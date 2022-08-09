# Kubernetes Control Plane

resource "yandex_compute_instance" "kubernetes-cp1" {
  name = "kubernetes-cp1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ju9iqf6g5bcq77jns"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "local_file" "external_ip_cp1" {
    content  = yandex_compute_instance.kubernetes-cp1.network_interface.0.nat_ip_address
    filename = "./outputs/external_ip_cp1.txt"
    file_permission = "0644"
}

resource "local_file" "internal_ip_cp1" {
    content  = yandex_compute_instance.kubernetes-cp1.network_interface.0.ip_address
    filename = "./outputs/internal_ip_cp1.txt"
    file_permission = "0644"
}


# Kubernetes Node 1

resource "yandex_compute_instance" "kubernetes-node1" {
  name = "kubernetes-node1"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ju9iqf6g5bcq77jns"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "local_file" "external_ip_node1" {
    content  = yandex_compute_instance.kubernetes-node1.network_interface.0.nat_ip_address
    filename = "./outputs/external_ip_node1.txt"
    file_permission = "0644"
}

resource "local_file" "internal_ip_node1" {
    content  = yandex_compute_instance.kubernetes-node1.network_interface.0.ip_address
    filename = "./outputs/internal_ip_node1.txt"
    file_permission = "0644"
}


# Kubernetes Node 2

resource "yandex_compute_instance" "kubernetes-node2" {
  name = "kubernetes-node2"
  zone = "ru-central1-b"  

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ju9iqf6g5bcq77jns"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_02.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "local_file" "external_ip_node2" {
    content  = yandex_compute_instance.kubernetes-node2.network_interface.0.nat_ip_address
    filename = "./outputs/external_ip_node2.txt"
    file_permission = "0644"
}

resource "local_file" "internal_ip_node2" {
    content  = yandex_compute_instance.kubernetes-node2.network_interface.0.ip_address
    filename = "./outputs/internal_ip_node2.txt"
    file_permission = "0644"
}


