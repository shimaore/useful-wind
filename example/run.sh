#!/bin/bash
PKG=`jq -r .name package.json`

# Make sure our dependencies are present.
npm install

# Start the Event Socket server
./node_modules/bin/coffee index.coffee.md
# Start FreeSwitch
docker run --rm -t -i --net host \
  --name $PKG-run \
  -v ${PWD}/conf:/opt/freeswitch/conf \
  shimaore/freeswitch \
  /opt/freeswitch/bin/freeswitch -nf -nosql -nonat -nonatmap -nocal -nort -c
