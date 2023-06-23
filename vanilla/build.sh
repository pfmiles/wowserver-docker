#!/bin/sh

BASE=$(dirname $0)

cd "$BASE" || exit

docker build -t vmangos-server:0.0.1 --build-arg="arch=arm64" .
