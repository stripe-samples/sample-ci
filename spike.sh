#!/bin/bash -xe

rm -rf accept-a-card-payment
git clone https://github.com/hibariya/accept-a-card-payment.git
cd accept-a-card-payment
git checkout tmp

# git clone https://github.com/stripe-samples/sample-ci.git
mkdir sample-ci; cp -pr ../{docker,.rspec,spec,Gemfile,helpers.sh} sample-ci/

source sample-ci/helpers.sh

install_dummy_tests
install_docker_compose_settings
export STRIPE_WEBHOOK_SECRET=$(retrieve_webhook_secret)
cat <<EOF >> .env
EOF

for lang in $(cat .cli.json | server_langs_for_integration decline-on-card-authentication)
do
  [ "$lang" = "php" ] && continue
  [ "$lang" = "node-typescript" ] && continue

  configure_docker_compose_for_integration decline-on-card-authentication "$lang" ../../client/web \
                                            target/accept-a-card-payment-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  docker-compose up -d && wait_web_server
  docker-compose exec -T runner bundle exec rspec spec/server_spec.rb
done

for lang in $(cat .cli.json | server_langs_for_integration using-webhooks)
do
  [ "$lang" = "php" ] && continue
  [ "$lang" = "node-typescript" ] && continue

  configure_docker_compose_for_integration using-webhooks "$lang" ../../client/web \
                                            target/collecting-card-payment-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  docker-compose up -d && wait_web_server
  if [ "$lang" = "java" ]; then
    docker-compose exec -T runner bundle exec rspec spec/server_spec.rb
  else
    docker-compose exec -T -e SERVER_ROOT_PATH=/checkout runner bundle exec rspec spec/server_spec.rb
  fi
done

for lang in $(cat .cli.json | server_langs_for_integration without-webhooks)
do
  [ "$lang" = "php" ] && continue
  [ "$lang" = "node-typescript" ] && continue

  configure_docker_compose_for_integration without-webhooks "$lang" ../../client/web \
                                            target/accept-a-card-payment-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  docker-compose up -d && wait_web_server
  docker-compose exec -T runner bundle exec rspec spec/server_spec.rb
done

docker-compose stop
