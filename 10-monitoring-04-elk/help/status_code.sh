#!/bin/sh

for (( i = 0; i <= 112; i++)); do
  curl -H "Content-Type: application/json" -XPOST "http://localhost:9200/logstash-01.09.2021/_doc" -d "{ \"status_code\" : \"200\", \"@timestamp\" : \"2021-09-01T17:32:00.457Z\"}"
done

for (( i = 0; i <= 356; i++)); do
  curl -H "Content-Type: application/json" -XPOST "http://localhost:9200/logstash-01.09.2021/_doc" -d "{ \"status_code\" : \"500\", \"@timestamp\" : \"2021-09-01T17:32:03.546Z\"}"
done