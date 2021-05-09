# devops-netology
## Это первое изменение файла.
Ничего полезного в нем пока нет.

## Новая информация!
Отслеживаться не будут следующие файлы в папке terraform:
* Любые файлы в любых вложенных папках, если в пути содержится .terraform: **/.terraform/*
* Все файлы с расширением .tfstate или содержащие в имени .tfstate:  *.tfstate   *.tfstate.*
* Все файлы с именем crash.log:   crash.log
* Все файлы с расширением .tfvars:   *.tfvars
* Файлы с именем override.tf, override.tf.json
* Файлы с именами, заказчивающимися на override.tf или override.tf.json:    *_override.tf  *_override.tf.json
* **Исключение: файл example_override.tf БУДЕТ ОТСЛЕЖИВАТЬСЯ:** !example_override.tf
* Единственный файл .terraformrc в папке terraform: .terraformrc
* Все файлы с именем terraform.rc:   terraform.rc

