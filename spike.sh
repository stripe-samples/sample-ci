#!/bin/bash -xe

git clone https://github.com/hibariya/checkout-single-subscription.git
cd checkout-single-subscription
git checkout ci

# git clone https://github.com/stripe-samples/sample-ci.git
mkdir sample-ci; cp -pr ../{configure_docker_compose,docker,functions.sh} sample-ci/

source sample-ci/functions.sh

cp -p sample-ci/docker/docker-compose.base.yml docker-compose.yml
touch .env;
export SAMPLE=NA SERVER_LANG=NA STATIC_DIR=NA
export STRIPE_WEBHOOK_SECRET=$(retrieve_webhook_secret)
cat <<EOF >> .env
DOMAIN=http://web:4242
BASIC_PRICE_ID=${BASIC}
PRO_PRICE_ID=${PREMIUM}
EOF

for lang in $(cat .cli.json | server_langs_for_integration main)
do
  [ "$lang" = "php" ] && continue

  echo > server/${lang}/.env
  sample-ci/configure_docker_compose . "$lang" ../../client \
                              target/single-subscription-checkout-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  docker-compose exec -T runner bundle exec rspec spec/server_spec.rb
done

docker-compose stop
