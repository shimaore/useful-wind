This is a complete, runnable example for `useful-wind` with a Docker.io FreeSwitch image.
The Docker image will run on your local interface (Docker's `--net host`) so you should be able to test with a standard SIP client.

Usage
-----

```shell
./run.sh
```

Application
-----------

The script doesn't do much besides issuing `answer` and then `sleep` commands, and logging DTMF.

    Server = require 'useful-wind/call_server'

    test =
      include: (ctx) ->
        @call.on 'DTMF', (res) ->
          digit = res.body['DTMF-Digit']
          console.log "Received #{digit}"

        @action 'answer'
        .then ->
          @action 'sleep', 100000

Configuration. In this case this only lists the middleware(s) we'll be using.

    cfg =
      use: [
        test
      ]

    server = new Server cfg
    server.listen 7000
