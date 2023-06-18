#!/bin/sh

BASE=`dirname $0`

cd "$BASE" || exit

docker build -t vmangos-local:0.0.1 --build-arg="arch=arm64" .
