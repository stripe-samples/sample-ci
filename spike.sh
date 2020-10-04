#!/bin/bash -e

sudo curl -o /usr/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
sudo chmod +x /usr/bin/jq

## stripe-samples/subscription-use-cases

export REPOSITORY_NAME=subscription-use-cases
git clone https://github.com/hibariya/${REPOSITORY_NAME}.git
cd "$REPOSITORY_NAME"
git checkout ci

cp -p ../run_tests .
cp ../docker/test.yml docker-compose.yml
cp ../docker/test/Dockerfile .
docker-compose build runner


export SAMPLE=fixed-price-subscriptions
export STATIC_DIR=../../client/vanillajs
export SERVER_JAR_FILE=target/subscriptions-with-fixed-price-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/fixed_price_server_spec.rb
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  touch ${SAMPLE}/server/${lang}/.env # FIXME: use .env file to load environment variables?
  export SERVER_LANG=$lang

  # TODO: want to move into a directory that won't conflict with existing files
  cp ../docker/${lang}.yml docker-compose.override.yml
  cp -pr ../docker/${lang} .

  ./run_tests "$TEST_FILES"
done


export SAMPLE=per-seat-subscriptions
export STATIC_DIR=../../client
export SERVER_JAR_FILE=target/subscriptions-with-per-seat-pricing-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/per_seat_server_spec.rb
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  touch ${SAMPLE}/server/${lang}/.env
  export SERVER_LANG=$lang

  cp ../docker/${lang}.yml docker-compose.override.yml
  cp -pr ../docker/${lang} .

  ./run_tests "$TEST_FILES"
done

export SAMPLE=usage-based-subscriptions
export STATIC_DIR=../../client
export SERVER_JAR_FILE=target/subscriptions-with-metered-usage-1.0.0-SNAPSHOT-jar-with-dependencies.jar
export TEST_FILES=spec/usage_based_server_spec.rb
rm -rf ${SAMPLE}/server/dotnet/ReportUsage # causes "Program.cs(14,28): error CS0017: Program has more than one entry point defined."
for lang in $(cat .cli.json | jq -r ".integrations[] | select(.name==\"${SAMPLE}\") | .servers | .[]")
do
  touch ${SAMPLE}/server/${lang}/.env
  export SERVER_LANG=$lang

  cp ../docker/${lang}.yml docker-compose.override.yml
  cp -pr ../docker/${lang} .

  ./run_tests "$TEST_FILES"
done
