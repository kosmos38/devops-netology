## Задача 1
>Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
>Подключитесь к БД PostgreSQL используя psql.
>Воспользуйтесь командой \? для вывода подсказки по имеющимся в psql управляющим командам.

Создаю volume для данных:

    docker volume create postgres_db
    docker volume ls

Запускаю контейнер:

```
docker run -it --rm -p 5432:5432 \
-v postgres_db:/var/lib/postgresql/data \
-e POSTGRES_PASSWORD=123 postgres:13
```

Подключаюсь к контейнеру:
 
    docker exec -it 86bfb3e7f026 bash

Подключаюсь в postrgesql:

    root@ad77008de42b:/# psql -U postgres

>Найдите и приведите управляющие команды для

вывода списка БД:

    postgres=# \l	

подключения к БД:

    \connect "db_name"

вывода списка таблиц:

    \dt

вывода описания содержимого таблиц:

    \d+ или \dt+ по всем таблицам

выхода из psql:
    
    \q


## Задача 2
>Используя psql создайте БД test_database.

    =# CREATE DATABASE test_database;
    =# \connect test_database

Восстановите бэкап БД в test_database.

    wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql
    psql -U postgres test_database < test_dump.sql

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице:

```
\connect test_database
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах:

```
test_database=# select MAX(avg_width) from pg_stats where tablename = 'orders';
 max
-----
  16
(1 row)

test_database=# select attname, MAX(avg_width) from pg_stats where tablename='orders' group by attname order by MAX(avg_width) desc nulls last;
 attname | max
---------+-----
 title   |  16
 id      |   4
 price   |   4
(3 rows)
```

## Задача 3
>Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и 
>поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в 
>нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
>Предложите SQL-транзакцию для проведения данной операции.

Шаг 1. Создание секций и создание условий:

```
create table orders_1 (like orders including all);
alter table orders_1 inherit orders;
alter table orders_1 add constraint check_price check (price > 499);

create table orders_2 (like orders including all);
alter table orders_2 inherit orders;
alter table orders_2 add constraint check_price check (price <= 499);
```

Проверим, что запросы уже используют секционирование:

```
test_database=# explain select * from orders where price=499;
                              QUERY PLAN
----------------------------------------------------------------------
 Append  (cost=0.00..15.87 rows=3 width=132)
   ->  Seq Scan on orders orders_1  (cost=0.00..1.10 rows=1 width=24)
         Filter: (price = 499)
   ->  Seq Scan on orders_2  (cost=0.00..14.75 rows=2 width=186)
         Filter: (price = 499)
(5 rows)
```

Шаг 2. Триггер на INSERT

```
test_database=# create function orders_ins () returns trigger as $$
test_database$# begin
test_database$#     if new.price > 499
test_database$#     then
test_database$#        insert into orders_1 select new.*;
test_database$#     elsif new.price <= 499
test_database$#     then
test_database$#        insert into orders_2 select new.*;
test_database$#     end if;
test_database$#     return null;
test_database$# end; $$ language plpgsql;
CREATE FUNCTION

create function orders_ins () returns trigger as $$
begin
    if new.price > 499
    then
       insert into orders_1 select new.*;
    elsif new.price <= 499
    then
       insert into orders_2 select new.*;
    end if;
    return null;
end; $$ language plpgsql;
CREATE FUNCTION

test_database=# create trigger orders_partition_ins
test_database-#     before insert on orders
test_database-#     for each row
test_database-#     execute procedure orders_ins();
CREATE TRIGGER

create trigger orders_partition_ins
    before insert on orders
    for each row
    execute procedure orders_ins();
```

Проверяем триггер:

```
test_database=# insert into orders values (9,'Linux для Чайников', 1500);
test_database=# insert into orders values (10,'Bash для начинающих', 200);

test_database=# select * from orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
  9 | Linux для Чайников   |  1500
 10 | Bash для начинающих  |   200
(10 rows)

test_database=# select * from only orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)
```

Шаг 3. Перенос данных

```
with del as (delete from only orders
        where price > 499
        returning *)
    insert into orders_1 select * from del;

with del as (delete from only orders
        where price <= 499
        returning *)
    insert into orders_2 select * from del;

test_database=# with del as (delete from only orders
test_database(#         where price > 499
test_database(#         returning *)
test_database-#     insert into orders_1 select * from del;
INSERT 0 3

test_database=# with del as (delete from only orders
test_database(#         where price <= 499
test_database(#         returning *)
test_database-#     insert into orders_2 select * from del;
INSERT 0 5
```

Проверяем:

```
test_database=# select * from only orders order by id;
 id | title | price
----+-------+-------
(0 rows)

test_database=# select * from orders order by id;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
  9 | Linux для Чайников   |  1500
 10 | Bash для начинающих  |   200
(10 rows)

test_database=# select * from only orders_1 order by id;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
  9 | Linux для Чайников |  1500
(4 rows)

test_database=# select * from only orders_2 order by id;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
 10 | Bash для начинающих  |   200
(6 rows)
```

Смотрим информацию о родительской таблице:

```
test_database=# \d+ orders
                                                       Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 title  | character varying(80) |           | not null |                                    | extended |              |
 price  | integer               |           |          | 0                                  | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Triggers:
    orders_partition_ins BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION orders_ins()
Child tables: orders_1,
              orders_2
Access method: heap
```

>Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Да, можно было, если сразу спроектировать как секционированную таблицу с предложением PARTITION BY, указав метод разбиения,
но как говориться в одной поговорке: знал бы прикуп, жил бы в Сочи ))

## Задача 4
>Используя утилиту pg_dump создайте бекап БД test_database

    pg_dump -U postgres -W test_database > /tmp/test_database.dump

>Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?

Добавил бы ограничение уникальности для столбца:

    title character varying(80) NOT NULL UNIQUE

