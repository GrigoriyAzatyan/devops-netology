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

`vault write pki_int/issue/example-dot-com common_name="netology.example.com" ttl="720h"`  

Key                 Value  
---                 -----  
ca_chain            [-----BEGIN CERTIFICATE-----  
MIIDpjCCAo6gAwIBAgIUeQ1cv6zc+7m6ZAR+o1POEqOgNn0wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjEwNzA0MTYxOTQ0WhcNMjIw
NzA0MTYyMDE0WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoSXTholz
ZDiQ0CRMvbk6tUzo+tK21Zhwe5uBSuS5lgGiJL5Hvl/44nlDlEs+NZABB04czEgs
tmdjFbK0yaz5C1hpMmaUZz9lIwl55/Rz6FPbyYZfucVEmSkCMxYqrPs5pTB4BN96
6ZFEN6VzRQzxTyxW5Qz1JCwMMgaNcKzl2X4RIhnMuaPlyuNbw1uc1XdIiEXohPjR
bAQElh3QEtkXWxDWqUAPmRcdpPfImKrIDGHsOK9graw1/PleN9QWZPbHbc2hgZNF
0YdrYw20SOC2n3iMmRhmFOP9UWEn4++h+5XZNpJfTaB1ynIIEYcvJyJ85StPcICl
Q9Pd2/r4/7K11wIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBStM36C8WRDYjNZNIAliV+D8btiODAfBgNVHSMEGDAW
gBQ/wchl1FnMBbv+WYLHt0v77TKzxzA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH
MAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm
oCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN
AQELBQADggEBAEcJhKBiXvpgeJ54e7cZUZy47AWvWJIcz3CVVG8pkjXSpXfOtwu7
jyIDBsxXRH9s9CfHbm5edl5ejPfGiJKU3L9ipkzb56Q3QcjXIBqj9vk3hvspY+Ri
8paJeyK5YvgPOes6n6LZ2zEqN3trJCurL1wqqtOORgX4qfUqaQTsaT2smaHcqduS
Pne7FtTrvvKCkC4zuj11jRrKyHSIh9/d9vBJZNsdeqf9+Uuqii+xgJixKWnlIjMz
4zv+ZdAOfuANic/65U7WiLT8V3JrA5QBsIciRWNGiVM1R7oFKlN4KU171ecFJSl3
R3AX7efyYNE8H2EPra+EyUsosLDY7AbweGQ=    
-----END CERTIFICATE-----]  
certificate         -----BEGIN CERTIFICATE-----  
MIIDbjCCAlagAwIBAgIUeyM9lME43T988OUk4tyy4qIDPL8wDQYJKoZIhvcNAQEL
BQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0
eTAeFw0yMTA3MDQxNjMxMzhaFw0yMTA4MDMxNjMyMDhaMB8xHTAbBgNVBAMTFG5l
dG9sb2d5LmV4YW1wbGUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEA3wMNhp7Yl1LwOu9sD7Q9xhs/ugAbAbCQ0ZBIvMGjgMklggwvme0C0oQ6+f4f
mX6/yW0PVrsGVZU9g5HL+guFgamF7UN1/6xtW2WXmcw9Ah/WiJx9zfRsjKpfTxuk
rKRrucImcPbW5fYJ5NKGq41m1igM13NJFECrqUDtTFR+cdkQapDWtSO3nRVPGNyo
rMjlELWgEcBPxIJYQYbbEfvShXNbaTYEPXtGZttzkudg35w53zkWMZIUq1KnCGjh
OBK9Fokyhn6HftZhJ8LfJKXr1rc7S8rNUXtmBl//V63ppkxWFKICzOwXoAtSK7wk
7egCDyDSc8aC4bj6BIsL5FV7bwIDAQABo4GTMIGQMA4GA1UdDwEB/wQEAwIDqDAd
BgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFPgMqWgBfyLP
DJpK/NzVgylTGHttMB8GA1UdIwQYMBaAFK0zfoLxZENiM1k0gCWJX4Pxu2I4MB8G
A1UdEQQYMBaCFG5ldG9sb2d5LmV4YW1wbGUuY29tMA0GCSqGSIb3DQEBCwUAA4IB
AQA/RAanFlGkbTHXXMtAQNoKbKaI2J3jblkbNaAKXRU7uFoTvw2Tvzm8KhkWQYxt
m36zuTUF4QtHV6mNAv90Bnba6/N6gu7VaUjVs1j1UmFR2TfbWfyDWijCfjvMekNC
atvTRYun4rjunNq62LFIcW/2+tArOa3CWwOLS9DO71K2oXSCDn7Yq7TmdX4h3Qr4
g8FzGtwEV2lfXJ3/8hc+fd+Vwk9tCI66it/AqW2Yfqk/GRG0PAQ9Ty+KljXzia53
FSATC4LVpIqb1JMxzqhyMJ6fSwCgtZGVgfTK1+5naTijxNiiMlb/HqjUzMzQBHNz
Uf7Gd90uoSaV9Tvy3Jt6mXAH  
-----END CERTIFICATE-----    
expiration          1628008328  
issuing_ca          -----BEGIN CERTIFICATE-----    
MIIDpjCCAo6gAwIBAgIUeQ1cv6zc+7m6ZAR+o1POEqOgNn0wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjEwNzA0MTYxOTQ0WhcNMjIw
NzA0MTYyMDE0WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoSXTholz
ZDiQ0CRMvbk6tUzo+tK21Zhwe5uBSuS5lgGiJL5Hvl/44nlDlEs+NZABB04czEgs
tmdjFbK0yaz5C1hpMmaUZz9lIwl55/Rz6FPbyYZfucVEmSkCMxYqrPs5pTB4BN96
6ZFEN6VzRQzxTyxW5Qz1JCwMMgaNcKzl2X4RIhnMuaPlyuNbw1uc1XdIiEXohPjR
bAQElh3QEtkXWxDWqUAPmRcdpPfImKrIDGHsOK9graw1/PleN9QWZPbHbc2hgZNF
0YdrYw20SOC2n3iMmRhmFOP9UWEn4++h+5XZNpJfTaB1ynIIEYcvJyJ85StPcICl
Q9Pd2/r4/7K11wIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBStM36C8WRDYjNZNIAliV+D8btiODAfBgNVHSMEGDAW
gBQ/wchl1FnMBbv+WYLHt0v77TKzxzA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH
MAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm
oCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN
AQELBQADggEBAEcJhKBiXvpgeJ54e7cZUZy47AWvWJIcz3CVVG8pkjXSpXfOtwu7
jyIDBsxXRH9s9CfHbm5edl5ejPfGiJKU3L9ipkzb56Q3QcjXIBqj9vk3hvspY+Ri
8paJeyK5YvgPOes6n6LZ2zEqN3trJCurL1wqqtOORgX4qfUqaQTsaT2smaHcqduS
Pne7FtTrvvKCkC4zuj11jRrKyHSIh9/d9vBJZNsdeqf9+Uuqii+xgJixKWnlIjMz
4zv+ZdAOfuANic/65U7WiLT8V3JrA5QBsIciRWNGiVM1R7oFKlN4KU171ecFJSl3
R3AX7efyYNE8H2EPra+EyUsosLDY7AbweGQ=  
-----END CERTIFICATE-----   
private_key         -----BEGIN RSA PRIVATE KEY-----    
MIIEpAIBAAKCAQEA3wMNhp7Yl1LwOu9sD7Q9xhs/ugAbAbCQ0ZBIvMGjgMklggwv
me0C0oQ6+f4fmX6/yW0PVrsGVZU9g5HL+guFgamF7UN1/6xtW2WXmcw9Ah/WiJx9
zfRsjKpfTxukrKRrucImcPbW5fYJ5NKGq41m1igM13NJFECrqUDtTFR+cdkQapDW
tSO3nRVPGNyorMjlELWgEcBPxIJYQYbbEfvShXNbaTYEPXtGZttzkudg35w53zkW
MZIUq1KnCGjhOBK9Fokyhn6HftZhJ8LfJKXr1rc7S8rNUXtmBl//V63ppkxWFKIC
zOwXoAtSK7wk7egCDyDSc8aC4bj6BIsL5FV7bwIDAQABAoIBABrOvSN/mL2oBKSw
/yZsHjjgMarkNFrhpKbsVzIJfOQQSef2Gwq/yOURbB19BMNozxkheQSN+tby17An
KIPoOqY5gJXi1B5l1cd00OJ2AKduuFU3qo/FX/8Qw+A4jHUMVr6/retKYM7H4qyU
+gdJOiFoMxL7Er/SflAcM+pHBeQdYCCuhqOXkpmyzxA8G+++Ux2Iwp0y+F40puQL
isaNXgeIwBX0KrdBHS8DkU3o/dCr1imi6XPh+2BrqjKZYCqnni39E4Dgb3ZznsTK
Qu05Lb1lB1SjH+AUn93qware7lEIyB7Z/JeFlCYo8pR0rboO6zAEAcUvUAmaDoJI
Wpw8mTECgYEA/wnajUtbeGGBeL/sGIyf1rduT5nXFYZQgrxKBE3hNwJAhjFdDOlI
R4MhlPoJ9iukOlHscjPy8lrXp8njB3+HHcFUqRaT1YFsCybBKBl6VhrfQs4vqZw/
geMLQ7mwzXIi0b1HcSc37o3Gm2KiJWmrckSvOFVcaskvFWbhfvT9jWMCgYEA39pK
CJz9A3bu/rzsRJxZk5XKElaViHQ77+JbGR5v216VToifjqWjeyX+GY+gZioiR8Yy
WUpDtzIpJzSHML405ap/bFKblw4Elc/XBmoebOaVM4Nwv6W/9G7lOLy1xr3XuHnc
Ty1mT9CG2dXMhdRI3pg7V2YxxahLwgeR3V/vDYUCgYEAo59wxgG414zHAe8vy7g8
vAbHEO7EHR0k/htK6WQFv8MEHpQA/M2V/7tTij64sWTiYkA5EDPgBDjf7tgJfcAF
scNdS3YetnXoGWdtuQpPgHqRDk02Kv0BiZVenr69fbFiQWnMMf5VVglDiGFJYfNf
eVoziFLLjf8w4+wzc74+Bb0CgYB27UAb51u8dXlvuOtFYFNux0u+BmYXQrl9LqL7
a2I+B7gHKyqp3HJIQN0Is3eiD4x62V9ydLQZJfsbKxsP2F2+DqD36cNjszzYYr14
WPSlIrPt1E0YZHTg5fG9/PQODFoJViSnpBURHlYmcSHhj/DO4c3VFyQmQM1O3jqu
hAM7CQKBgQDtDdA8/mrS3CgcZuzcYOltVkJ/e6ZPpbwEIV+AIMGsulFyZurvQJd+
1jpPJrROnx/6vk4WCbOBfLvf8s2XpqFSIbJLEZouM2B/iL1aXYXei5iQ5kI9DkRo
daVWX0xxZ7XtHfrdB/7NLDhz/MgBULeqysw/nY3SrRjXDIQdCBfnfA==  
-----END RSA PRIVATE KEY-----  
private_key_type    rsa  
serial_number       7b:23:3d:94:c1:38:dd:3f:7c:f0:e5:24:e2:dc:b2:e2:a2:03:3c:bf  



# 5. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.  

apt -y install nginx  
mkdir -p /var/www/netology.example.com/public_html  
chown -R www-data:www-data /var/www/netology.example.com/public_html
chmod 755 /var/www  
`tee /var/www/netology.example.com/public_html/index.html <<EOF`  
`<html>`  
  `<head>`  
    `<title>netology.example.com</title>`  
  `</head>`  
  `<body>`  
    `<h1>NETOLOGY!</h1>`  
  `</body>`  
`</html>`  
`EOF`  

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/netology.example.com
nano /etc/nginx/sites-available/netology.example.com

`server {`    
        `listen 443 ssl;`    
        `root /var/www/netology.example.com/public_html;`    
        `index index.html index.htm;`    
        `server_name netology.example.com; `   
        `ssl_certificate     /etc/nginx/ssl/netology.example.com.crt;`    
        `ssl_certificate_key /etc/nginx/ssl/netology.example.com.key;`    
`}`     
 
ln -s /etc/nginx/sites-available/netology.example.com /etc/nginx/sites-enabled/netology.example.com   
mkdir /etc/nginx/ssl  
** В /etc/nginx/ssl/netology.example.com.crt подсунул цепочку сертификатов. Сертификат узла пришлось поместить первым, иначе nginx отваливался. **  
systemctl restart nginx 


# 6. Модифицировав /etc/hosts и системный trust-store, добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.  

nano /etc/hosts  
127.0.0.1       localhost       netology.example.com  
127.0.1.1       vagrant.vm      vagrant  

**nano /etc/nginx/ssl/ca.crt**  
Подсовываем сюда промежуточный сертификат:  
-----BEGIN CERTIFICATE-----
MIIDpjCCAo6gAwIBAgIUeQ1cv6zc+7m6ZAR+o1POEqOgNn0wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjEwNzA0MTYxOTQ0WhcNMjIw
NzA0MTYyMDE0WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoSXTholz
ZDiQ0CRMvbk6tUzo+tK21Zhwe5uBSuS5lgGiJL5Hvl/44nlDlEs+NZABB04czEgs
tmdjFbK0yaz5C1hpMmaUZz9lIwl55/Rz6FPbyYZfucVEmSkCMxYqrPs5pTB4BN96
6ZFEN6VzRQzxTyxW5Qz1JCwMMgaNcKzl2X4RIhnMuaPlyuNbw1uc1XdIiEXohPjR
bAQElh3QEtkXWxDWqUAPmRcdpPfImKrIDGHsOK9graw1/PleN9QWZPbHbc2hgZNF
0YdrYw20SOC2n3iMmRhmFOP9UWEn4++h+5XZNpJfTaB1ynIIEYcvJyJ85StPcICl
Q9Pd2/r4/7K11wIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBStM36C8WRDYjNZNIAliV+D8btiODAfBgNVHSMEGDAW
gBQ/wchl1FnMBbv+WYLHt0v77TKzxzA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH
MAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm
oCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN
AQELBQADggEBAEcJhKBiXvpgeJ54e7cZUZy47AWvWJIcz3CVVG8pkjXSpXfOtwu7
jyIDBsxXRH9s9CfHbm5edl5ejPfGiJKU3L9ipkzb56Q3QcjXIBqj9vk3hvspY+Ri
8paJeyK5YvgPOes6n6LZ2zEqN3trJCurL1wqqtOORgX4qfUqaQTsaT2smaHcqduS
Pne7FtTrvvKCkC4zuj11jRrKyHSIh9/d9vBJZNsdeqf9+Uuqii+xgJixKWnlIjMz
4zv+ZdAOfuANic/65U7WiLT8V3JrA5QBsIciRWNGiVM1R7oFKlN4KU171ecFJSl3
R3AX7efyYNE8H2EPra+EyUsosLDY7AbweGQ=
-----END CERTIFICATE-----

ln -s /etc/nginx/ssl/ca.crt /usr/local/share/ca-certificates/example-ca.crt
update-ca-certificates


Результат в виртуальной машине:  
![Результат в виртуальной машине](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/ssl_nginx_1.jpg)

Результат на хосте:  
![Результат на хосте](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/ssl_nginx.jpg)


# 7. Ознакомьтесь с протоколом ACME и CA Let's encrypt. Если у вас есть во владении доменное имя с платным TLS-сертификатом, который возможно заменить на LE, или же без HTTPS вообще, попробуйте воспользоваться одним из предложенных клиентов, чтобы сделать веб-сайт безопасным (или перестать платить за коммерческий сертификат).  

Протокол ACME применяется для организации взаимодействия удостоверяющего центра и web-сервера, например, для автоматизации получения и обслуживания сертификатов. Запросы передаются в формате JSON поверх HTTPS.  
Проект разработан некоммерческим удостоверяющим центром Let’s Encrypt, контролируемым сообществом и предоставляющим сертификаты безвозмездно всем желающим.  

Получить сертификат Let’s Encrypt на локальную виртуальную машину не представилось возможным, т.к. для этого нужен публичный доступ по 80 порту, зарегистрированное публичное доменое имя и соответствующая DNS-запись.  
Инструкция по настройке Certbot на Ubuntu 20: https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx

# Дополнительное задание вне зачета. Вместо ручного подкладывания сертификата в nginx, воспользуйтесь consul-template для автоматического подтягивания сертификата из Vault.  
