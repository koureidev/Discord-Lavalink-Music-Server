#!/bin/sh
set -e

: "${LAVALINK_PASSWORD:=youshallnotpass}"
: "${SERVER_PORT:=2333}"

envsubst < /app/application.yml.template > /app/application.yml

exec java -Xmx768m -Xms256m -jar Lavalink.jar
