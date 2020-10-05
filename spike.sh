#!/bin/bash -xe

# Clone a sample repository and copy sample-ci files into it
export REPOSITORY_NAME=subscription-use-cases
git clone https://github.com/hibariya/${REPOSITORY_NAME}.git
cd "$REPOSITORY_NAME"
git checkout ci

cp -pr ../ci .
export COMPOSE_FILE=ci/docker/docker-compose.base.yml
docker-compose build runner # runner runs RSpec tests for each sample


# The exported environment variables will be read by ci/docker/.env and ci/docker/docker-compose.base.yml
export SAMPLE=fixed-price-subscriptions
export STATIC_DIR=../../client/vanillajs
export SERVER_JAR_FILE=target/subscriptions-with-fixed-price-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/fixed_price_server_spec.rb
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  echo > ${SAMPLE}/server/${lang}/.env # Empty the file since the process on the container already has those environment variables
  export SERVER_LANG=$lang
  export COMPOSE_FILE=ci/docker/docker-compose.base.yml:ci/docker/${lang}/docker-compose.web.yml

  ./ci/run_tests "$TEST_FILES" # Build containers and run $TEST_FILES
done


# Do over again for per-seat-subscriptions
export SAMPLE=per-seat-subscriptions
export STATIC_DIR=../../client
export SERVER_JAR_FILE=target/subscriptions-with-per-seat-pricing-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/per_seat_server_dummy_spec.rb # spec/per_seat_server_spec.rb will fail on python, see fail_per_seat_python.sh
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  echo > ${SAMPLE}/server/${lang}/.env
  export SERVER_LANG=$lang
  export COMPOSE_FILE=ci/docker/docker-compose.base.yml:ci/docker/${lang}/docker-compose.web.yml

  ./ci/run_tests "$TEST_FILES"
done


# For usage-based-subscriptions
export SAMPLE=usage-based-subscriptions
export STATIC_DIR=../../client
export SERVER_JAR_FILE=target/subscriptions-with-metered-usage-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/usage_based_server_spec.rb
rm -rf ${SAMPLE}/server/dotnet/ReportUsage # causes "Program.cs(14,28): error CS0017: Program has more than one entry point defined."
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  echo > ${SAMPLE}/server/${lang}/.env
  export SERVER_LANG=$lang
  export COMPOSE_FILE=ci/docker/docker-compose.base.yml:ci/docker/${lang}/docker-compose.web.yml

  ./ci/run_tests "$TEST_FILES"
done

docker-compose stop
