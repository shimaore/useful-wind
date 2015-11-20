A Promise-friendly, middleware-based framework for FreeSwitch call-handling
===========================================================================

This framework is based on the [esl](https://github.com/shimaore/esl) Node.js Event Socket interface.

It consists of two objects:
- the call-server provides a high-level interface to a middle-ware based route; look in the [`example`](https://github.com/shimaore/useful-wind/tree/master/example) folder for a complete, working example;
- the router is the lower-level machinery; it works similarly to a Sinatra-based middleware router: each middleware is called in turn for a given call.

Router
======

    Router = require 'useful-wind/router'

The router is initialized with a single parameter which is made available inside the middleware as `this.cfg`.

    cfg = {my_db_name:'foo'}
    router = new Router cfg

Each middleware is called once for each FreeSwitch call; middleware functions are called inside a Promise chain, using a specific context which is described in the next section.

`router.session` (object)
----------------

The router's `session` object is used to initialize the middlewares' `session` object.

    router.session.db = new PouchDB cfg.db_name, cfg.db_options

`router.use` (function or object)
------------

Appends the middleware to the list of middleware used by this router.

The argument might be a function, or an object with the fields `include` and (for debugging purposes) `name`.

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

`router.session` is used to initialize `session` at the start of each call, before any middleware is processed.

`data`
------

The data provided by FreeSwitch over the Event Socket.

A shortcut for `this.call.data`.

`source`
--------

The FreeSwitch Caller-ID-Number.

Your application may modify `source` if you'd like, but the value is not sent back to FreeSwitch. Use the FreeSwitch `set` or `export` commands to do that.

`destination`
-------------

The FreeSwitch Destination-Number.

Your application may modify `destination` if you'd like, but the value is not sent back to FreeSwitch. Use the FreeSwitch `set` or `export` commands to do that.

`req.variable` (function)
------------

Return a reference to a (read-only) FreeSwitch variable:

    router.use ->
      if @req.variable('direction')
        console.log 'direction is present'

`req.header` (function)
------------

Return a reference to the incoming SIP header:

    router.use ->
      if @req.header('p-charge-info')
        console.log 'P-Charge-Info is present'

`action` (function)
--------

A shortcut for `call.command`. Send a command to FreeSwitch.

    router.use ->
      @action 'set', 't38_passthru=true'
      .then ->
        @action 'bridge', 'sofia/profile/fax@192.168.2.1'
