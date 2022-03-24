# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl

Создал два ConfigMaps: в одном [conf файл](configmap-nginx.yaml), в другом [environments](configmap-env-nginx.yaml):

```
$ kubectl apply -f configmap-env-nginx.yaml
configmap/nginx-env created

$ kubectl apply -f configmap-nginx.yaml
configmap/nginx-conf created
```

Проверяю объекты:

```
$ kubectl get configmaps -n prod
NAME               DATA   AGE
kube-root-ca.crt   1      31d
nginx-conf         1      3m31s
nginx-env          2      73s
```

```
$ kubectl describe configmap nginx-conf -n prod
Name:         nginx-conf
Namespace:    prod
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
user www-data;
pid /run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
  multi_accept on;
  worker_connections 65535;
}

http {
```

```
$ kubectl describe configmap nginx-env -n prod
Name:         nginx-env
Namespace:    prod
Labels:       <none>
Annotations:  <none>

Data
====
HOSTNAME:
----
netology.ru
STUDENT:
----
Anton M. Ivanov

BinaryData
====

Events:  <none>
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Подготовил [deploy для образа nginx](deploy-nginx.yaml), с пробросом конфигурационного файла через ConfigMap:

```
$ kubectl apply -f deploy-nginx.yaml
deployment.apps/nginx created
```

Проверяю ENV:

```
$ kubectl exec -it nginx-7565d4d7b8-54tmj bash -n prod
root@nginx-758489769f-mlj8n:/# env | grep HOSTNAME
HOSTNAME=netology.ru
root@nginx-758489769f-mlj8n:/# env | grep STUDENT
STUDENT=Anton M. Ivanov

```

Проверяю подключение своего конфигурационного файла:

```
root@nginx-7565d4d7b8-54tmj:/# cat /etc/nginx/nginx.conf
user www-data;
pid /run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
  multi_accept on;
  worker_connections 65535;
}

http {
  charset utf-8;
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  server_tokens off;
  log_not_found off;
  types_hash_max_size 2048;
  client_max_body_size 16M;

  # MIME
  include mime.types;
  default_type application/octet-stream;

  # logging
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log warn;

  # load configs
  include /etc/nginx/conf.d/*.conf;

  # netology.ru
  server {
    listen 80;
    listen [::]:80;

    server_name netology.ru;
    set $base /var/www/netology.ru;
    root $base/public;
```