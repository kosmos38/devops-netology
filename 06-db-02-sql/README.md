## Задача 1
>Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
>Приведите получившуюся команду или docker-compose манифест.

Создаю volume:

	docker volume create postgres_db
	docker volume create postgres_backup

Запускаю контейнер из образа postgres:12 с подключенными двумя volume:

	docker run -it --rm -p 5432:5432 \
	-v postgres_db:/var/lib/postgresql/data \
	-v postgres_backup:/tmp \
	-e POSTGRES_PASSWORD=123 postgres:12

Подключаюсь к контейнеру с хостовой машины:

	psql -h 127.0.0.1 -p 5432 -U postgres

## Задача 2
>В БД из задачи 1:
>создайте пользователя test-admin-user и БД test_db
>в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
>предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
>создайте пользователя test-simple-user
>предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Создаю базу:

	CREATE DATABASE test_db;
	select * from pg_database;

Создаю пользователей и назначаю права:

	CREATE USER "test-admin-user" WITH password 'qwe';
	select * from pg_shadow;
	GRANT ALL ON DATABASE test_db TO "test-admin-user";

	CREATE USER "test-simple-user" WITH password 'asd';

Подключаюсь к postgres от вновь созданного пользователя:

	psql -h 127.0.0.1 -p 5432 -U test-admin-user -d test_db

Создание таблиц:

```CREATE TABLE orders
(
    id SERIAL PRIMARY KEY,
    наименование CHARACTER VARYING(30),
    цена INTEGER
);

CREATE TABLE clients
(
	id SERIAL PRIMARY KEY,	
	фамилия CHARACTER VARYING(30),
	"страна проживания" CHARACTER VARYING(30),
	заказ INTEGER,
	FOREIGN KEY (заказ) REFERENCES orders (id)
);
CREATE INDEX ON clients("страна проживания");
```

Выдача прав на таблицы:

	GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE orders,clients TO "test-simple-user";

Итоговый список БД после выполнения пунктов выше:

```test_db=> \dt public.*
             List of relations
 Schema |  Name   | Type  |      Owner
--------+---------+-------+-----------------
 public | clients | table | test-admin-user
 public | orders  | table | test-admin-user
(2 rows)
```

Описание таблиц (describe):

```test_db=> \d+ orders
                                                          Table "public.orders"
    Column    |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 наименование | character varying(30) |           |          |                                    | extended |              |
 цена         | integer               |           |          |                                    | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap

test_db=> \d+ clients
                                                             Table "public.clients"
      Column       |         Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description
-------------------+-----------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer               |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 фамилия           | character varying(30) |           |          |                                     | extended |              |
 страна проживания | character varying(30) |           |          |                                     | extended |              |
 заказ             | integer               |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_страна проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap
```

SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:

	SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='orders';
	SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='clients';

Список пользователей с правами над таблицами test_db:

```
     grantee      | privilege_type
------------------+----------------
 test-admin-user  | INSERT
 test-admin-user  | SELECT
 test-admin-user  | UPDATE
 test-admin-user  | DELETE
 test-admin-user  | TRUNCATE
 test-admin-user  | REFERENCES
 test-admin-user  | TRIGGER
 test-simple-user | INSERT
 test-simple-user | SELECT
 test-simple-user | UPDATE
 test-simple-user | DELETE
(11 rows)
```

## Задача 3
>Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

```test_db=> INSERT INTO orders(наименование, цена) VALUES(Шоколад, 10);
test_db=> INSERT INTO orders(наименование, цена) VALUES('Принтер', 3000);
...
test_db=> select * from orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)

test_db=> INSERT INTO clients(фамилия, "страна проживания") VALUES('Иванов Иван Иванович', 'USA');
test_db=> select * from clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |
  2 | Петров Петр Петрович | Canada            |
  3 | Иоганн Себастьян Бах | Japan             |
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
(5 rows)
```

Вычислите количество записей для каждой таблицы:

```
test_db=> SELECT count(*) FROM clients;
 count
-------
     5
(1 row)

test_db=> SELECT count(*) FROM orders;
 count
-------
     5
(1 row)
```

## Задача 4
>Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
>Используя foreign keys свяжите записи из таблиц, согласно таблице:

Проверяю работу внешнего ключа, используя несуществующий id = 6

	test_db=> UPDATE clients SET заказ = 6 WHERE фамилия = 'Иванов Иван Иванович';
	ERROR:  insert or update on table "clients" violates foreign key constraint "clients_заказ_fkey"
	DETAIL:  Key (заказ)=(6) is not present in table "orders".

```
UPDATE clients SET заказ = 5 WHERE фамилия = 'Иоганн Себастьян Бах';
test_db=> SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```
test_db=> SELECT * FROM clients WHERE заказ IS NOT NULL;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

## Задача 5
>Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).
>Приведите получившийся результат и объясните что значат полученные значения.

```
test_db=> EXPLAIN
test_db-> SELECT * FROM clients WHERE заказ IS NOT NULL;
                         QUERY PLAN
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..14.20 rows=418 width=164)
   Filter: ("заказ" IS NOT NULL)
(2 rows)


test_db=> EXPLAIN ANALYZE
SELECT * FROM clients WHERE заказ IS NOT NULL;
                                              QUERY PLAN
------------------------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..14.20 rows=418 width=164) (actual time=0.010..0.012 rows=3 loops=1)
   Filter: ("заказ" IS NOT NULL)
   Rows Removed by Filter: 2
 Planning Time: 0.050 ms
 Execution Time: 0.027 ms
(5 rows)
```

cost: стоимость запроса
rows: число записей, обработанных для получения выходных данных
Planning Time: 0.050 ms		План
Execution Time: 0.027 ms	Факт


## Задача 6
>Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
>Остановите контейнер с PostgreSQL (но не удаляйте volumes).
>Поднимите новый пустой контейнер с PostgreSQL.
>Восстановите БД test_db в новом контейнере.
>Приведите список операций, который вы применяли для бэкапа данных и восстановления.

pg_dump является автономной утилитой, поэтому выполняем её не SQL запросом, а из консоли контейнера:

	root@f6e8f55d2279:/# pg_dump -U postgres -W test_db > /tmp/test_db.dump

Остановил и удалил контейнер postgres:

	docker rm f6e8f55d2279

Очистил volume с данными:

	rm -rf * /var/lib/docker/volumes/postgres_db/_data/

Стартую новый контейнер:

```
docker run -it --rm -p 5432:5432 \
-v postgres_db:/var/lib/postgresql/data \
-v postgres_backup:/tmp \
-e POSTGRES_PASSWORD=123 postgres:12
```

Подключаюсь:

	docker exec -it 86bfb3e7f026 bash

Смотрю листинг баз:

```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

Создаю базу:

	postgres=# CREATE DATABASE test_db;
	
Создаю пользователя, который ранее владел базой:

	postgres=# CREATE USER "test-admin-user" WITH password qwe;

Назначаю права:

	postgres=# GRANT ALL ON DATABASE test_db TO "test-admin-user";

Восстанавливаю базу из дампа:

	root@86bfb3e7f026:/# psql -U postgres -W test_db < /tmp/test_db.dump

Подключаюсь к восстановленной базе:

	root@86bfb3e7f026:/# psql -U test-admin-user -W -d test_db

Проверяю:

```
test_db=> \d+
                                List of relations
 Schema |      Name      |   Type   |      Owner      |    Size    | Description
--------+----------------+----------+-----------------+------------+-------------
 public | clients        | table    | test-admin-user | 8192 bytes |
 public | clients_id_seq | sequence | test-admin-user | 8192 bytes |
 public | orders         | table    | test-admin-user | 8192 bytes |
 public | orders_id_seq  | sequence | test-admin-user | 8192 bytes |
(4 rows)

test_db=> SELECT * FROM clients WHERE заказ IS NOT NULL;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```
