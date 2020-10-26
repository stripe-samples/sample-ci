retrieve_webhook_secret() {
  docker-compose pull stripe > /dev/null 2>&1
  docker-compose run -T --rm stripe -c '/bin/stripe listen --api-key $STRIPE_SECRET_KEY --print-secret'
}

install_docker_compose_settings() {
  variables='${SAMPLE}${SERVER_LANG}${STATIC_DIR}${SERVER_JAR_FILE}${STRIPE_WEBHOOK_SECRET}'
  cat $(dirname "$0")/docker/docker-compose.base.yml | envsubst "$variables" > docker-compose.yml
  cat $(dirname "$0")/docker/${SERVER_LANG}/docker-compose.web.yml | envsubst "$variables" > docker-compose.override.yml
}

wait_web_server() {
  time docker-compose exec -T runner bash -c 'curl -I --retry 12 --retry-delay 3 --retry-connrefused $SERVER_URL'
}

server_langs_for_integration() {
  integration=${1:-main}
  jq -r ".integrations[] | select(.name==\"${integration}\") | .servers | .[]"
}
