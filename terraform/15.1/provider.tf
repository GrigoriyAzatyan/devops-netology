terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.76.0"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1gccc2qa4rr7iff92ad"
  folder_id = "b1g8da5bj6a5bkfb01kr"
  zone      = "ru-central1-a"
}

