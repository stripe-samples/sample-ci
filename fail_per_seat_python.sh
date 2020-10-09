#!/bin/bash -xe

export REPOSITORY_NAME=subscription-use-cases
git clone https://github.com/hibariya/subscription-use-cases.git
cd subscription-use-cases
git checkout ci

cp -pr ../ci .
cp -p ci/docker/docker-compose.base.yml docker-compose.yml
docker-compose build runner # runner runs RSpec tests for each sample

sample=per-seat-subscriptions
lang=python
ci/configure_docker_compose "$sample" "$lang" ../../client \
                            target/subscriptions-with-per-seat-pricing-1.0.0-SNAPSHOT-jar-with-dependencies.jar

echo > ${sample}/server/${lang}/.env
ci/run_tests spec/per_seat_server_spec.rb
