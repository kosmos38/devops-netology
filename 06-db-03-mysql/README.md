Задача 1

docker volume create mysql_db
docker volume create mysql_backup

docker run -it -p 3306:3306 \
-v mysql_db:/var/lib/mysql \
-v mysql_backup:/tmp \
-e MYSQL_ROOT_PASSWORD=123 -d mysql:8.0

Скачиваю дамп:
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql

Создаю пустую базу для восстановления дампа:
mysql> create database test_db;

Восстанавливаю базу из дампа:
root@1dc041fdcead:/# mysql -u root -p test_db < /tmp/test_dump.sql

Вывод статуса версии сервера БД:
mysql> \s
--------------
mysql  Ver 8.0.25 for Linux on x86_64 (MySQL Community Server - GPL)

Подключаюсь к базе и выбираю данные:
mysql> use test_db;
mysql> select * from orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)



Задача 2

CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass';
ALTER USER 'test'@'localhost' ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
ALTER USER 'test'@'localhost' PASSWORD EXPIRE INTERVAL 180 DAY;
ALTER USER 'test'@'localhost' FAILED_LOGIN_ATTEMPTS 3;
ALTER USER 'test'@'localhost' WITH MAX_QUERIES_PER_HOUR 100;


mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
==================================================================================

Выдаю пользователю тест права SELECT на базу test_db:
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.15 sec)


Задача 3

mysql> SET profiling = 1;

mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------------+
| Query_ID | Duration   | Query                                                 |
+----------+------------+-------------------------------------------------------+
|        1 | 0.00017850 | SELECT DATABASE()                                     |
|        2 | 0.00102950 | show databases                                        |
|        3 | 0.00159175 | show tables                                           |
|        4 | 0.55570350 | create table clients (id int, name varchar(30))       |
|        5 | 0.00152950 | show tables                                           |
+----------+------------+-------------------------------------------------------+
5 rows in set, 1 warning (0.00 sec)

В нашей базе таблицы используют движок InnoDB:
mysql> SELECT TABLE_NAME,ENGINE,ROW_FORMAT,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;
+------------+--------+------------+------------+-------------+--------------+
| TABLE_NAME | ENGINE | ROW_FORMAT | TABLE_ROWS | DATA_LENGTH | INDEX_LENGTH |
+------------+--------+------------+------------+-------------+--------------+
| clients    | InnoDB | Dynamic    |          0 |       16384 |            0 |
| orders     | InnoDB | Dynamic    |          5 |       16384 |            0 |
+------------+--------+------------+------------+-------------+--------------+
2 rows in set (0.04 sec)


Изменил движок на MyISAM:
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.51 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
|       22 | 0.51674675 | ALTER TABLE orders ENGINE = MyISAM


Изменил движок на InnoDB:
mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.80 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
|       23 | 0.80093225 | ALTER TABLE orders ENGINE = InnoDB


Задача 4
На моем виртуальном "сервере" 2Gb RAM, исходя из этого:
my.cnf
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# InnoDB tuning
innodb_buffer_pool_size		= 1432M
innodb_log_file_size		= 100M
innodb_log_buffer_size		= 1M
innodb_file_per_table		= 1
innodb_flush_method		= O_DIRECT
innodb_flush_log_at_trx_commit	= 2

# Custom config should go here
!includedir /etc/mysql/conf.d/





