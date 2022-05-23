#!/bin/bash

set -o allexport
if [[ -f .env ]]; then
  source .env
fi
set +o allexport

export APP_PORT="$PORT"
export APP_HOST="0.0.0.0"
export APP_CONNECT="http"

find_services_with_tag () {
  TAG=${1}
  echo "$VCAP_SERVICES" | jq "to_entries | map(.value) | flatten | map(select((.tags | index(\"${TAG}\")))) | .[]"
}

mysql_services=$(find_services_with_tag "mysql")

if [[ -n "$mysql_services" ]]; then
  db_env=$(echo "$mysql_services" | jq '.credentials | "export DB_CONNECTION=mysql\nexport DB_HOST=\(.hostname // .host)\nexport DB_PORT=\(.port)\nexport DB_DATABASE=\(.name)\nexport DB_USERNAME=\(.username)\nexport DB_PASSWORD=\(.password)"' -r)
  eval "$db_env"
fi

github_client_services=$(find_services_with_tag "github-client")

if [[ -n "$github_client_services" ]]; then
  github_client_env=$(echo "$github_client_services" | jq '.credentials | "export GITHUB_CLIENT_ID=\(.id)\nexport GITHUB_CLIENT_SECRET=\(.secret)"' -r)
  eval "$github_client_env"
fi


github_webhook_services=$(find_services_with_tag "github-webhook")

if [[ -n "$github_webhook_services" ]]; then
  github_webhook_env=$(echo "$github_webhook_services" | jq '.credentials | "export META_SECRET=\(.secret)"' -r)
  eval "$github_webhook_env"
fi
