# 1. Установите Hashicorp Vault в виртуальной машине Vagrant/VirtualBox. Это не является обязательным для выполнения задания, но для лучшего понимания что происходит при выполнении команд (посмотреть результат в UI), можно по аналогии с netdata из прошлых лекций пробросить порт Vault на localhost:  
    config.vm.network "forwarded_port", guest: 8200, host: 8200  
**Однако, обратите внимание, что только-лишь проброса порта не будет достаточно – по-умолчанию Vault слушает на 127.0.0.1; добавьте к опциям запуска -dev-listen-address="0.0.0.0:8200".**  

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -  
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"  
sudo apt-get update && sudo apt-get install vault  
systemctl enable vault --now  
nano /lib/systemd/system/vault.service  
`...`  
`ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl -dev-listen-address="0.0.0.0:8200"`  
`...`  
systemctl daemon-reload  
systemctl restart vault  
nano /etc/vault.d/vault.hcl  

    # HTTP listener
    listener "tcp" {
      address = "0.0.0.0:8200"
      tls_disable = 1
    }

    # HTTPS listener
    listener "tcp" {
      address       = "0.0.0.0:8201"
      tls_cert_file = "/opt/vault/tls/tls.crt"
      tls_key_file  = "/opt/vault/tls/tls.key"
    }

export VAULT_ADDR=http://127.0.0.1:8200  
vault status  
  
    Key             Value  
    ---             -----  
    Seal Type       shamir  
    Initialized     true  
    Sealed          false  
    Total Shares    5  
    Threshold       3  
    Version         1.7.3  
    Storage Type    file  
    Cluster Name    vault-cluster-c3644d31  
    Cluster ID      b9063944-4483-df3f-157c-44db78aa7fc4  
    HA Enabled      false  
  
vault operator init  
vault login  
vault secrets enable -path=secret/ kv  
vault login  
vault secrets enable -path=secret/ kv  
vault kv put secret/hello foo=world  
vault kv get secret/hello  
`=== Data ===`  
`Key    Value`  
`---    -----`  
`foo    world`  


# 2. Запустить Vault-сервер в dev-режиме (дополнив ключ -dev упомянутым выше -dev-listen-address, если хотите увидеть UI).  
![Скриншот](https://s722sas.storage.yandex.net/rdisk/ddc91a9fccb8c696db882ba5b9bcf7075736e009f4dd50fed8b524f34bed8334/60e20cdd/JMeYnk0Z_KW3CXVEKh7m3hZCSTgEymCHOk44VKkzgN04lprVc4enSFeC68GpymOowc4MAZCi9EnYx_07qAzxxg==?uid=0&filename=vault.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&owner_uid=0&fsize=148130&hid=33a2ed7594be58d8d0b62e94a179340a&media_type=image&tknv=v2&etag=1a9b424ac9c8fb58388fcc1fe3f43ebf&rtoken=fOmKJEtpIO2g&force_default=no&ycrid=na-97af86d8b0cecf6049ea31ec3a1ae739-downloader22f&ts=5c65140c73140&s=708f30dee7c760944d873c120a0dcfa7d3a37cdcf7bf5f2f8f8e6a2b5462fd70&pb=U2FsdGVkX1816nA9iofDRBteZ0oZuu3oTAWwXvQjGQ4GFSfvKamAE7SFF3r5HQrBemuUWK-YfU4ZxpRZazWqzopDASwLJtsJRQVu7DXOFy0)

# 3. Используя PKI Secrets Engine, создайте Root CA и Intermediate CA. Обратите внимание на дополнительные материалы по созданию CA в Vault, если с изначальной инструкцией возникнут сложности.  

    tee root-policy.hcl <<EOF
    # Read system health check
    path "sys/health"
    {
      capabilities = ["read", "sudo"]
    }

    # Create and manage ACL policies broadly across Vault

    # List existing policies
    path "sys/policies/acl"
    {
      capabilities = ["list"]
    }

    # Create and manage ACL policies
    path "sys/policies/acl/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    # Enable and manage authentication methods broadly across Vault

    # Manage auth methods broadly across Vault
    path "auth/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    # Create, update, and delete auth methods
    path "sys/auth/*"
    {
      capabilities = ["create", "update", "delete", "sudo"]
    }

    # List auth methods
    path "sys/auth"
    {
      capabilities = ["read"]
    }

    # Enable and manage the key/value secrets engine at `secret/` path

    # List, create, update, and delete key/value secrets
    path "secret/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    # Manage secrets engines
    path "sys/mounts/*" {
      capabilities = [ "create", "read", "update", "delete", "list" ]
    }

    # List enabled secrets engine
    path "sys/mounts" {
      capabilities = [ "read", "list" ]
    }

    # Work with pki secrets engine
    path "pki*" {
      capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
    }
    EOF

    vault policy write admin admin-policy.hcl
    vault secrets enable pki
    vault secrets tune -max-lease-ttl=8760h pki
    vault write -field=certificate pki/root/generate/internal common_name="example.com" ttl=87600h > CA_cert.crt
    vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
    vault write pki/roles/example-dot-com allowed_domains=my-website.com allow_subdomains=true max_ttl=72h
    vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
    vault secrets enable -path=pki_int pki
    vault secrets tune -max-lease-ttl=43800h pki_int
    vault write -format=json pki_int/intermediate/generate/internal common_name="example.com Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
    vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
    vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
    vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"

# 4. Согласно этой же инструкции, подпишите Intermediate CA csr на сертификат для тестового домена (например, netology.example.com если действовали согласно инструкции).  


# 5. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.  


# 6. Модифицировав /etc/hosts и системный trust-store, добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.  


# 7. Ознакомьтесь с протоколом ACME и CA Let's encrypt. Если у вас есть во владении доменное имя с платным TLS-сертификатом, который возможно заменить на LE, или же без HTTPS вообще, попробуйте воспользоваться одним из предложенных клиентов, чтобы сделать веб-сайт безопасным (или перестать платить за коммерческий сертификат).  


# Дополнительное задание вне зачета. Вместо ручного подкладывания сертификата в nginx, воспользуйтесь consul-template для автоматического подтягивания сертификата из Vault.  
