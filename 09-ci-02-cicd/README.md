# Домашнее задание к занятию "09.02 CI\CD"

## SonarQube

Запуск sonar-scanner:

```
sonar-scanner \
  -Dsonar.projectKey=netology \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://192.168.134.11:9000 \
  -Dsonar.login=088728380ae693c27089d1294c7671ed41b280a8 \
  -Dsonar.coverage.exclusions=fail.py
```

```
kosmos@centos8:~$ sonar-scanner --version
INFO: Scanner configuration file: /home/kosmos/sonarqube/sonar-scanner-4.6.2.2472-linux/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.6.2.2472
INFO: Java 11.0.11 AdoptOpenJDK (64-bit)
INFO: Linux 4.18.0-305.7.1.el8_4.x86_64 amd64
```

Скриншоты скриншот успешного прохождения анализа:

https://ibb.co/pZMxCPZ

https://ibb.co/m9Nv5xy

Файл [fail.py](https://github.com/kosmos38/mnt-netology/blob/master/09-ci-02-cicd/fail.py)

## Nexus

[maven-metadata.xml](https://github.com/kosmos38/mnt-netology/blob/master/09-ci-02-cicd/maven-metadata.xml)

Скриншот работы Nexus:

https://ibb.co/MfXBXQ8

## Maven

Файл [pom.xml](https://github.com/kosmos38/mnt-netology/blob/master/09-ci-02-cicd/pom.xml)

Запуск Maven:

```
kosmos@centos8:~$ mvn --version
Apache Maven 3.8.1 (05c21c65bdfed0f71a2f2ada8b84da59348c4c5d)
Maven home: /home/kosmos/maven/apache-maven-3.8.1
Java version: 11.0.12, vendor: Red Hat, Inc., runtime: /usr/lib/jvm/java-11-openjdk-11.0.12.0.7-0.el8_4.x86_64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "4.18.0-305.7.1.el8_4.x86_64", arch: "amd64", family: "unix"
```

Результат работы mvn package:

```
[INFO] Building jar: /home/kosmos/maven/target/simple-app-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  1.224 s
[INFO] Finished at: 2021-08-03T19:21:29+08:00
[INFO] ------------------------------------------------------------------------
```

Содержимое директории:

```
kosmos@centos8:~$ ls ~/.m2/repository/netology/
java
```