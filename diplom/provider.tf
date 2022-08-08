terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.76.0"
    }
  }
}

terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "netology-azatyan"
    region = "ru-central1"
    key = "terraform/backend.tfstate"
    access_key = "YCAJEs2fLgf9Vd5p2D1h7ZJQ7"
    secret_key = "YCNnsuAx3vsABo__SliREP9S3iCaRoyTzFKaUjKn"
    skip_region_validation = true
    skip_credentials_validation = true
   }
}

provider "yandex" {
  service_account_key_file = file("key.json")
  cloud_id  = "b1gccc2qa4rr7iff92ad"
  folder_id = "b1g8da5bj6a5bkfb01kr"
  zone      = "ru-central1-a"
}
