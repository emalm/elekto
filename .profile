#!/bin/bash

set -o allexport
source .env
set +o allexport

export APP_PORT="$PORT"
export APP_HOST="0.0.0.0"
export APP_CONNECT="http"

mysql_services=$(echo "$VCAP_SERVICES" | jq 'to_entries | map(.value) | flatten | map(select((.tags | index("mysql")))) | .[]')

if [[ -n "$mysql_services" ]]; then
  db_env=$(echo "$mysql_services" | jq '.credentials | "export DB_CONNECTION=mysql\nexport DB_HOST=\(.hostname)\nexport DB_PORT=\(.port)\nexport DB_DATABASE=\(.name)\nexport DB_USERNAME=\(.username)\nexport DB_PASSWORD=\(.password)"' -r)
  eval "$db_env"
fi
