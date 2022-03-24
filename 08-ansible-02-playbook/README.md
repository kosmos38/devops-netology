# Работа с Playbook

Данный `playbook` производит автоматическую установку и настройку продуктов java, elasticsearch, kibana в docker контейнеры на основе образа pycontribs/centos:7

## Структура каталогов

```
.
└── playbook
    ├── files
    ├── group_vars
    │   ├── all
    │   ├── elasticsearch
    │   └── kibana
    ├── inventory
    └── templates

8 directories
```
* Директория `files` предназначена для локального хранения файлов, которые в процессе исполнения tasks копируются на удаленные хосты
* Директрия `group_vars/all` предназначена для хранения глобальных переменных, которые применяются для всех хостов
* Директория `group_vars/elasticsearch` хранит переменные для группы хостов на которые устанавливается elasticsearch
* Директория `group_vars/kibana` хранит переменные для группы хостов на которые устанавливается kibana
* Директория `inventory` содержит файлы с группами хостов
* Директория `templates` содержит `.sh` файлы с экспортируемыми переменными окружения на удаленные хосты

## Описание `site.yml`

Playbook `site.yml` состоит из трёх `play`, каждый `play` тэгирован:

* Install Java              `(tag: java)`
* Install Elasticsearch     `(tag: elatic)`
* Install Kibana            `(tag: kibana)`

### play `Install Java` состоит из нескольких задач:

* `Set facts for Java 11 vars` установка переменной `java_home`
* `Upload .tar.gz file...` выгрузка установочных файлов из локального каталога на удаленную машину
* `Create directrory for java` создание домашней директории java на удаленной машине
* `Extract java in the installation directory` извлекаем bin файлы от пользователя с повышенными привилегиями, используя `become`, при помощи модуля `unarchive`
* `Export environment variables` экспортируем переменные окружения из файла templates/jdk.sh.j2

### play `Install Elasticsearch` состоит из задач:

* `Upload tar.gz Elasticsearch` загрузка установочных файлов при помощи модулья get_url с оф. сайта с проверкой until, до тех пор пока не скачается и игнорированием ошибок SSL трафика
* `Create directrory for Elasticsearch` создание домашней директории elasticsearch на удаленной машине
* `Extract Elasticsearch....` извлекаем bin файлы от пользователя с повышенными привилегиями используя `become`, при помощи модуля `unarchive`
* `Set environment Elastic` экспортируем переменные окружения из файла templates/elk.sh.j2

### play `Install Kibana` состоит из задач:

* `Upload tar.gz Kibana from remote URL` загрузка установочных файлов при помощи модулья get_url с оф. сайта с проверкой until, до тех пор пока не скачается и игнорированием ошибок SSL трафика
* `Create directrory for Kibana` создание домашней директории elasticsearch на удаленной машине
* `Extract Kibana in the...` извлекаем bin файлы от пользователя с повышенными привилегиями, используя `become`, при помощи модуля `unarchive`
* `Set environment Kibana` экспортируем переменные окружения из файла templates/kibana.sh.j2
* `Upload config file kibana` копируем конфигурационный файл kibana.yml из локальной директории files в директорию `/opt/kibana/7.13.2/config/` на удаленную машину

## Запуск playbook

        ansible-playbook site.yml -i inventory/prod.yml