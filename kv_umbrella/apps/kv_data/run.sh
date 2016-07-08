#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Parameter Error! Use: ./run.sh data_name"
	exit 1
fi

iex --name "${1}@127.0.0.1" -S mix
