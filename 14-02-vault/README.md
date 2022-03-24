# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

Создал отдельный ns для выполнения дз, запустил под vault:

```
$ kubectl create ns vault
namespace/vault created

$ kubectl apply -f deploy-vault-pod.yaml
pod/14.2-netology-vault created
```

Проверил состояние:
```
$ kubectl get po -n vault
NAME                  READY   STATUS              RESTARTS   AGE
14.2-netology-vault   0/1     ContainerCreating   0          12s
```

Узнал IP пода vault:

```
$ kubectl get pod 14.2-netology-vault -n vault -o json | jq -c '.status.podIPs'
[{"ip":"10.233.103.49"}]
```

Запустил под с fedora:

```
$ kubectl run -i --tty fedora --image=fedora --restart=Never -n vault -- bash
```

Подготовил скрипт pip, havc и сам скрипт:

```
[root@fedora /]# cd /opt/
[root@fedora opt]# touch get-secret.py
[root@fedora opt]# vi get-secret.py
[root@fedora opt]# cat get-secret.py
import hvac
client = hvac.Client(
    url='http://10.233.103.49:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

Вывод секрета в fedora:
```
[root@fedora opt]# python3 get-secret.py
{'request_id': 'c1290373-f5f1-ac13-b840-e305f04203af', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2021-12-03T17:01:44.9788562Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 3}}, 'wrap_info': None, 'warnings': None, 'auth': None}
```