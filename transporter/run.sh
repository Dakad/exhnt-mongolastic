#!/bin/bash
set -ev
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

printf "\nIN TRANSPORTER SETUP\n"

MONGO=`ping -c 1 mongo-rs0-1 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
ES=`ping -c 1 elasticsearch | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
MARKER=/scripts/.TRANSPORTER_STARTED

# Cleanup from previous runs
if test -f "$MARKER"; then
    rm $MARKER
fi

# Cleanup from previous runs
if test -f "$MARKER"; then
  rm $MARKER
fi

cd $GOPATH; mkdir pkg
mkdir -p src/github.com/compose; cd src/github.com/compose
git clone --depth 1 --branch v0.2.2 https://github.com/compose/transporter; cd transporter

echo "Getting dependencies and building.."
go build -a ./cmd/transporter/...

#curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

#go get github.com/tools/godep
#godep restore
#godep go build ./cmd/...
#godep go install ./cmd/...


/scripts/wait-until-mongodb-started.sh

# Signal that we're starting
printf "=====================================\n\n"
printf Touching file
printf "=====================================\n\n"
touch $MARKER

cd /transporter
transporter run --config ./config.yaml ./mongo-es.js
