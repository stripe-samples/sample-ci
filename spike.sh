#!/bin/bash -xe

# Clone a sample repository and copy sample-ci files into it
git clone https://github.com/hibariya/subscription-use-cases.git
cd subscription-use-cases
git checkout ci

cp -pr ../ci .
cp -p ci/docker/docker-compose.base.yml docker-compose.yml

export SAMPLE=NA; export SERVER_LANG=NA; export STATIC_DIR=NA;
docker-compose build runner # runner runs RSpec tests for each sample

server_langs_in_sample() {
  jq -r ".integrations[] | select(.name==\"${1}\") | .servers | .[]"
}

sample=fixed-price-subscriptions
for lang in $(cat .cli.json | server_langs_in_sample "$sample")
do
  ci/configure_docker_compose "$sample" "$lang" ../../client/vanillajs \
                              target/subscriptions-with-fixed-price-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  echo > ${sample}/server/${lang}/.env # Empty the file since the process on the container already has those environment variables
  ci/run_tests spec/fixed_price_server_spec.rb # Build containers and run tests
done

sample=per-seat-subscriptions
for lang in $(cat .cli.json | server_langs_in_sample "$sample")
do
  ci/configure_docker_compose "$sample" "$lang" ../../client \
                              target/subscriptions-with-per-seat-pricing-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  echo > ${sample}/server/${lang}/.env
  ci/run_tests spec/per_seat_server_dummy_spec.rb # spec/per_seat_server_spec.rb will fail on python, see fail_per_seat_python.sh
done

sample=usage-based-subscriptions
rm -rf ${sample}/server/dotnet/ReportUsage # causes "Program.cs(14,28): error CS0017: Program has more than one entry point defined."
for lang in $(cat .cli.json | server_langs_in_sample "$sample")
do
  ci/configure_docker_compose "$sample" "$lang" ../../client \
                              target/subscriptions-with-metered-usage-1.0.0-SNAPSHOT-jar-with-dependencies.jar

  echo > ${sample}/server/${lang}/.env
  ci/run_tests spec/usage_based_server_spec.rb
done

docker-compose stop
