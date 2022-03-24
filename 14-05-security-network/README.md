# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Контейнер из шаблона запустил, настройки secutirty-context применились:

```
root@kube-master1:/home/kosmos$ kubectl get po -n prod | grep security
security-context-demo       0/1     Completed   5 (92s ago)     3m36s

root@kube-master1:/home/kosmos$ kubectl logs security-context-demo -n prod
uid=1000 gid=3000 groups=3000

```

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Для решение задачи применил 3 политики:

[default-deny-egress](default-deny-egress.yaml)

[network-policy-1](network-policy-1.yaml)

[network-policy-2](network-policy-2.yaml)


Запустил для тестов два пода в namespace prod:

```
kubectl run -i --tty nginx-curl-1 --image=ewoutp/docker-nginx-curl:latest --restart=Never -n prod -- bash
kubectl run -i --tty nginx-curl-2 --image=ewoutp/docker-nginx-curl:latest --restart=Never -n prod -- bash
```

Проверка связи с внешним миром:

```
root@nginx-curl-1:/usr/local/nginx/html# ping ya.ru
PING ya.ru (87.250.250.242): 56 data bytes
64 bytes from 87.250.250.242: icmp_seq=0 ttl=245 time=67.706 ms
64 bytes from 87.250.250.242: icmp_seq=1 ttl=245 time=67.801 ms

root@nginx-curl-2:/usr/local/nginx/html# ping ya.ru
PING ya.ru (87.250.250.242): 56 data bytes
64 bytes from 87.250.250.242: icmp_seq=0 ttl=245 time=68.965 ms
64 bytes from 87.250.250.242: icmp_seq=1 ttl=245 time=67.989 ms
```

Применил политику default-deny-egress (полностью запретил подам исходящую связь):

```
root@nginx-curl-1:/usr/local/nginx/html#ping ya.ru
^C

root@nginx-curl-2:/usr/local/nginx/html#ping ya.ru
^C
```

Применил политику network-policy-1.yaml (доступ в интернет есть, доступ к 2-му контейнеру есть, к другим хостам нет):

```
root@nginx-curl-1:/usr/local/nginx/html# ping ya.ru
PING ya.ru (87.250.250.242): 56 data bytes
64 bytes from 87.250.250.242: icmp_seq=0 ttl=245 time=68.154 ms
64 bytes from 87.250.250.242: icmp_seq=1 ttl=245 time=67.838 ms
^C--- ya.ru ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/stddev = 67.838/67.996/68.154/0.158 ms

root@nginx-curl-1:/usr/local/nginx/html# ping 10.233.103.65
PING 10.233.103.65 (10.233.103.65): 56 data bytes
64 bytes from 10.233.103.65: icmp_seq=0 ttl=63 time=0.145 ms
64 bytes from 10.233.103.65: icmp_seq=1 ttl=63 time=0.095 ms
^C--- 10.233.103.65 ping statistics ---

root@nginx-curl-1:/usr/local/nginx/html# ping 10.233.89.20
PING 10.233.89.20 (10.233.89.20): 56 data bytes
^C--- 10.233.89.20 ping statistics ---
13 packets transmitted, 0 packets received, 100% packet loss
```


Применил политику network-policy-2.yaml (разрешил 2-му контейнеру обращаться к 1-му, доступ в другие сети заркыт):

```
root@nginx-curl-2:/usr/local/nginx/html# ping 10.233.103.64
PING 10.233.103.64 (10.233.103.64): 56 data bytes
64 bytes from 10.233.103.64: icmp_seq=0 ttl=63 time=0.249 ms
64 bytes from 10.233.103.64: icmp_seq=1 ttl=63 time=0.161 ms
^C--- 10.233.103.64 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.161/0.205/0.249/0.044 ms

root@nginx-curl-2:/usr/local/nginx/html# ping ya.ru
^C
```

