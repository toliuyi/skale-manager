#!/bin/bash

export $(cat .env | xargs) 

npx oz upgrade --network ${NETWORK} --all || exit $?
npx truffle deploy --f 2 --to 2 --network ${NETWORK} || exit $?
