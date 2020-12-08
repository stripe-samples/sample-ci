#!/bin/bash -e

if [[ "$#" -eq "0" ]]; then
  exec dotnet run --urls http://0.0.0.0:4242
else
  exec "$@"
fi
