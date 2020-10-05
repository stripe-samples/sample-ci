#!/bin/bash -xe

export REPOSITORY_NAME=subscription-use-cases
git clone https://github.com/hibariya/${REPOSITORY_NAME}.git
cd "$REPOSITORY_NAME"
git checkout ci

cp -pr ../ci .
export COMPOSE_FILE=ci/docker/docker-compose.base.yml
docker-compose build runner


lang=python
export SAMPLE=per-seat-subscriptions
export STATIC_DIR=../../client
export TEST_FILES=spec/per_seat_server_spec.rb
export SERVER_LANG=$lang
export COMPOSE_FILE=ci/docker/docker-compose.base.yml:ci/docker/${lang}/docker-compose.web.yml

echo > ${SAMPLE}/server/${lang}/.env
./ci/run_tests "$TEST_FILES"

docker-compose stop
