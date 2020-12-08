#!/bin/bash -e

if [[ "$#" -eq "0" ]]; then
  bundle install -j4 --quiet
  exec tail -f /dev/null
else
  exec "$@"
fi
