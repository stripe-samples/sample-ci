retrieve_webhook_secret() {
  docker-compose pull stripe > /dev/null 2>&1
  docker-compose run -T --rm stripe -c '/bin/stripe listen --api-key $STRIPE_SECRET_KEY --print-secret'
}

install_docker_compose_settings() {
  touch .env;

  (
    export SAMPLE=NA SERVER_LANG=NA STATIC_DIR=NA STRIPE_WEBHOOK_SECRET=NA
    variables='${SAMPLE}${SERVER_LANG}${STATIC_DIR}${STRIPE_WEBHOOK_SECRET}'
    cat sample-ci/docker/docker-compose.base.yml | envsubst "$variables" > docker-compose.yml
  )
}

configure_docker_compose_for_integration() {
  install_docker_compose_settings_for_integration "$1" "$2" "$3" "$4"

  echo > ${1}/server/${2}/.env
  docker-compose stop web || true
  time docker-compose build web
}

install_docker_compose_settings_for_integration() {
  (
    export SAMPLE=${1}
    export SERVER_LANG=${2}
    export STATIC_DIR=${3}

    variables='${SAMPLE}${SERVER_LANG}${STATIC_DIR}${STRIPE_WEBHOOK_SECRET}'
    cat sample-ci/docker/docker-compose.base.yml | envsubst "$variables" > docker-compose.yml
    cat sample-ci/docker/${SERVER_LANG}/docker-compose.web.yml | envsubst "$variables" > docker-compose.override.yml
  )
}

wait_web_server() {
  time docker-compose exec -T runner bash -c 'curl -I --retry 12 --retry-delay 3 --retry-connrefused $SERVER_URL'
}

server_langs_for_integration() {
  integration=${1:-main}
  jq -r ".integrations[] | select(.name==\"${integration}\") | .servers | .[]"
}

install_dummy_tests() {
  cp -pr sample-ci/spec .
  cp -p sample-ci/.rspec .
  cp -p sample-ci/Gemfile .
}

setup_dependencies() {
  __sudo apt update
  __sudo apt install gettext-base

  __sudo curl -o /usr/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  __sudo chmod +x /usr/bin/jq

  if [ -n "$ACT" ]; then
    # https://docs.docker.com/engine/install/debian/
    # https://docs.docker.com/compose/install/
    curl -fsSL https://get.docker.com | __sudo sh -
    __sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    __sudo chmod +x /usr/local/bin/docker-compose
  fi
}

__sudo() {
  if [ -x "$(which sudo)" ]; then
    sudo "$@"
  else
    "$@"
  fi
}
