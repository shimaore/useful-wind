#!/bin/bash
PKG=useful-wind

# Make sure our dependencies are present.
npm install

# Start the Event Socket server
./node_modules/.bin/coffee index.coffee.md &
# Start FreeSwitch
docker run --rm -t -i --net host \
  --name $PKG-run \
  -v ${PWD}/conf:/opt/freeswitch/conf \
  shimaore/freeswitch:4.0.7 \
  /opt/freeswitch/bin/freeswitch -nf -nosql -nonat -nonatmap -nocal -nort -c
# Type `shutdown` in the FreeSwitch console to stop it.
