#!/bin/bash -e

if [[ "$#" -eq "0" ]]; then
  bundle install -j4 --quiet
  exec bundle exec ruby server.rb -o 0.0.0.0
else
  exec "$@"
fi
