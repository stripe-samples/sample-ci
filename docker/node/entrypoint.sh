#!/bin/bash -e

if [[ "$#" -eq "0" ]]; then
  npm install -q
  exec npm start
else
  exec "$@"
fi
