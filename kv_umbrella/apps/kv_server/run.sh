#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Parameter Error! Use: ./run.sh number"
  exit 1
fi

iex --name "orchestrator${1}@127.0.0.1" --erl "-config config/orchestrator${1}" -S mix
