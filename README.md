A Promise-friendly, middleware-based framework for FreeSwitch call-handling
===========================================================================

    Router = require 'useful-wind'

The router is initialized with a single parameter which is made available inside the middleware as `this.cfg`.

    cfg = {db_name:'foo'}
    router = new Router cfg

Each middleware is called once for each FreeSwitch call; middleware functions are called inside a Promise chain, using a specific context which is described in the next section.

`router.session` (object)
----------------

The router's `session` object is used to initialize the middlewares' `session` object.

    router.session.db = new PouchDB cfg.db_name, cfg.db_options

`router.use` (function or object)
------------

Appends the middleware to the list of middleware used by this router.

The argument might be a function, or an object with the field `include` and (optionally, for debugging purposes) `name`.

debug
-----

This module uses `debug` and the prefix `useful-wind`. Use `DEBUG='useful-wind:*'` or a similar pattern to debug the module (including errors in middleware code).


Middleware context
==================

Middleware functions are called using the following context (which means the `this` object has the following properties).
This context is also available as the first and only argument to middleware functions.

`cfg`
-----

The object that was passed to the constructor for the router.
A shortcut to `this.router.cfg`.

`router`
--------

A reference to the router object.

`router.session` is used to initialize `session` at the start of each call, before any middleware is processed.

`session`
---------

Middleware should store call-related data inside the `session` object:

    router.use ->
      @session.from_number = @source.replace /^+/, ''

    router.use ->

        if @destination is '123'
          @action 'bridge', 'sofia/profile/voicemail@services.example.net'
        else

          @session.db.get "number:#{destination}"
          .then (doc) ->

`data`
------

The data provided by FreeSwitch over the Event Socket.

`source`
--------

The FreeSwitch Caller-ID-Number.

Your application may modify `destination` if you'd like, but the value is not sent back to FreeSwitch. Use the FreeSwitch `set` or `export` commands to do that.

`destination`
-------------

The FreeSwitch Destination-Number.

Your application may modify `destination` if you'd like, but the value is not sent back to FreeSwitch. Use the FreeSwitch `set` or `export` commands to do that.

`req.header` (function)
------------

Return a reference to the incoming SIP header:

    router.use ->
      if req.header('p-charge-info')
        console.log 'P-Charge-Info is present'

`action` (function)
--------

Send a command to FreeSwitch.

    router.use ->
      @action 'set', 't38_passthru=true'
      .then ->
        @action 'bridge', 'sofia/profile/fax@192.168.2.1'

`include` (function)
---------

Requires a module, which should export an `include` function, which is called the same way a middleware is called.
This allows you to compose modules.
