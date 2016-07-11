#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Parameter Error! Use: ./run.sh client_name [rpc|http]"
	exit 1
fi

iex --name "${1}@127.0.0.1" -S mix run --config ./config/config.exs.${2}
