## Задача 1

>Используя докер образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:
>
>составьте Dockerfile-манифест для elasticsearch
>
>соберите docker-образ и сделайте push в ваш docker.io репозиторий 
>
>запустите контейнер из получившегося образа и выполните запрос пути / c хост-машины 

На хост машине установил:
  
    sysctl -w vm.max_map_count=262144
    more /proc/sys/vm/max_map_count

Получившийся Dockerfile:
    
    root@centos:/docker/netology_elastic$ cat Dockerfile

Конфигурацию в elasticsearch передавал поэтапно по ходу настройки, 
поэтому через echo, можно было подкинуть файл конфига через ADD:

```
FROM centos:7

RUN yum update -y && \
yum install -y perl-Digest-SHA && \
yum install -y wget

RUN groupadd elastic && \
useradd elastic -g elastic -p elasticsearch

WORKDIR /opt

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.1-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.1-linux-x86_64.tar.gz.sha512 && \
shasum -a 512 -c elasticsearch-7.12.1-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-7.12.1-linux-x86_64.tar.gz

RUN chown -R elastic:elastic /opt/elasticsearch-7.12.1

ENV ES_HOME=/opt/elasticsearch-7.12.1
ENV ES_JAVA_HOME=/opt/elasticsearch-7.12.1/jdk
ENV ES_JAVA_OPTS="-Xms128m -Xmx128m"

RUN mkdir /var/lib/elasticsearch && \
mkdir /var/lib/elasticsearch/snapshots && \
chown -R elastic:elastic /var/lib/elasticsearch

RUN echo "xpack.ml.enabled: false" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "cluster.name: netology" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "node.name: netology_test" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "network.host: 0.0.0.0" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "http.host: 0.0.0.0" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "http.port: 9200" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "path.data: /var/lib/elasticsearch" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "path.logs: /var/lib/elasticsearch" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "path.repo: /var/lib/elasticsearch/snapshots" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "discovery.seed_hosts: 127.0.0.1, [::1]" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml && \
echo "cluster.initial_master_nodes: netology_test" >> /opt/elasticsearch-7.12.1/config/elasticsearch.yml

EXPOSE 9200 9300

WORKDIR /opt/elasticsearch-7.12.1/bin

ENV PATH=$PATH:/opt/elasticsearch-7.12.1/bin
USER elastic

CMD ["elasticsearch"]
```

Запуск контейнера:

    root@centos:/$ docker run --rm -it -p 9200:9200 4a82a494618a

Ответ системы:
```
root@centos:/docker/netology_elastic$ curl http://192.168.100.2:9200/
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "AjDIAKRZTN2VVXcZglGQnQ",
  "version" : {
    "number" : "7.12.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3186837139b9c6b6d23c3200870651f10d3343b7",
    "build_date" : "2021-04-20T20:56:39.040728659Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```


## Задача 2

Получите список индексов и их статусов, используя API и приведите в ответе на задание:
```
root@centos:/docker/netology_elastic$ curl -X GET "192.168.100.2:9200/_cat/indices?pretty"
green  open ind-1 OVdpnK6iSfahl3v1PtXAqw 1 0 0 0 208b 208b
yellow open ind-3 w-7gCMcBR1mRIyXTVOED0g 4 2 0 0 832b 832b
yellow open ind-2 DtqY738wTIyE388Lvm2K-w 2 1 0 0 416b 416b
```

Получите состояние кластера elasticsearch, используя API:
```
root@centos:/docker/netology_elastic$ curl -X GET "192.168.100.2:9200/_cat/health?pretty"
1621505639 10:13:59 netology yellow 1 1 7 7 0 0 10 0 - 41.2%

root@centos:/docker/netology_elastic$ curl -X GET "192.168.100.2:9200/_cat/shards?pretty"
ind-3 2 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 2 r UNASSIGNED
ind-3 2 r UNASSIGNED
ind-3 1 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 1 r UNASSIGNED
ind-3 1 r UNASSIGNED
ind-3 3 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 3 r UNASSIGNED
ind-3 3 r UNASSIGNED
ind-3 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 0 r UNASSIGNED
ind-3 0 r UNASSIGNED
ind-1 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 1 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 1 r UNASSIGNED
ind-2 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 0 r UNASSIGNED

root@centos:/docker/netology_elastic$ curl -X GET "192.168.100.2:9200/_cat/nodes?pretty"
172.17.0.2 73 93 5 0.05 0.16 0.11 cdfhimrstw * netology_test
```

>Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Потому что при проектировании кластера мы создали всего лишь одну ноду, а индексы создали с репликами и шардами. 
Индексам некуда реплицироваться. Шардам некуда привязаться.

Удалите все индексы:

    curl -X DELETE "192.168.100.2:9200/_all?pretty"


## Задача 3

>Создайте директорию {путь до корневой директории с elasticsearch в образе}/snapshots.

```
mkdir /var/lib/elasticsearch/snapshots
path.repo: /var/lib/elasticsearch/snapshots

root@centos:/docker/netology_elastic$ curl -X PUT "192.168.100.2:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "t> {
>   "type": "fs",
>   "settings": {
>     "location": "my_backup_location"
>   }
> }
> '
{
  "acknowledged" : true
}
```

>Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов:

    root@centos:/docker/netology_elastic$ curl http://192.168.100.2:9200/_cat/indices/
    green open test tGxGhjHDS_6wHE7P1RHvtw 1 0 0 0 208b 208b

>Создайте snapshot состояния кластера elasticsearch:

    curl -X PUT "192.168.100.2:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty"

>Приведите в ответе список файлов в директории со snapshotами:

    [elastic@9a8320576d9c bin]$ ls /var/lib/elasticsearch/snapshots/my_backup_location/
    index-0  index.latest  indices  meta--RLAQn9ySC29mi35G6JSOQ.dat  snap--RLAQn9ySC29mi35G6JSOQ.dat

>Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.
```
curl -X DELETE "192.168.100.2:9200/test?pretty"

root@centos:/docker/netology_elastic$ curl http://192.168.100.2:9200/_cat/indices/
green open test-2 hB13JI89TTW-SqukXiwOHA 1 0 0 0 208b 208b
```

>Восстановите состояние кластера elasticsearch из snapshot, созданного ранее:
```
curl -X POST "192.168.100.2:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty"

root@centos:/docker/netology_elastic$ curl http://192.168.100.2:9200/_cat/indices/
green open test-2 hB13JI89TTW-SqukXiwOHA 1 0 0 0 208b 208b
green open test   3wYY7NGGTbKQfDsLl8QlXg 1 0 0 0 208b 208b
```
