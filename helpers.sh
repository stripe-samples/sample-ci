retrieve_webhook_secret() {
  docker-compose pull stripe > /dev/null 2>&1
  docker-compose run -T --rm stripe -c '/bin/stripe listen --api-key $STRIPE_SECRET_KEY --print-secret'
}

install_docker_compose_settings() {
  touch .env;

  install_docker_compose_settings_for_integration "NA" "NA" "NA"

  docker-compose run --entrypoint=/bin/sh runner -c true
  docker cp . $(docker-compose ps -qa runner | head -1):/work/
}

configure_docker_compose_for_integration() {
  [[ "$1" = "main" ]] && sample="." || sample="$1"
  server_type=${2}
  static_dir=${3}

  echo "### Configuring the settings for the integration; sample: ${sample}, server_type: ${server_type}, static_dir: ${static_dir}"

  install_docker_compose_settings_for_integration "$sample" "$server_type" "$static_dir"

  docker-compose stop web || true
  docker-compose build web

  # NOTE: On the CI, this function call is the only chance to copy the env file that contains proper values;
  #       maybe we should re-write ci.yml on each sample repository and remove this.
  docker cp .env $(docker-compose ps -qa runner | head -1):/work/${sample}/server/${server_type}/ || true
}

install_docker_compose_settings_for_integration() {
  (
    export SAMPLE=${1}
    export SERVER_TYPE=${2}
    export STATIC_DIR=${3}

    variables='${SAMPLE}${SERVER_TYPE}${STATIC_DIR}'
    cat sample-ci/docker/docker-compose.yml | envsubst "$variables" > docker-compose.yml
  )
}

wait_web_server() {
  docker-compose exec -T runner bash -c 'curl -I --retry 15 --retry-delay 3 --retry-connrefused $SERVER_URL'
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
