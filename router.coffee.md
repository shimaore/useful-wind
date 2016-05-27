    module.exports = class UsefulWindRouter
      constructor: (@cfg = {}) ->
        debug 'constructor cfg =', @cfg
        @middlewares = []
        @session = {}

router.use
==========

      use: (middleware) ->

Middleware might be one of two things:
- a function, in which case it is a `include`-only middleware
- an object, in which case it must have an `include` entity as the middleware

At this point it should either be a function or an object.

        if typeof middleware is 'function'
          middleware = include:middleware

At this point it should only be an object; the object must have an `include` function.

        middleware.name ?= '(no name)'

        if typeof middleware.include is 'function'

Add the middleware for in-call use.

          @middlewares.push middleware
        else
          debug "Middleware #{middleware.name}'s `include` must be a function", typeof middleware.include

      route: (call) ->
        source = call.data['Channel-Caller-ID-Number']
        destination = call.data['Channel-Destination-Number']

The above works fine if we are executing inside the XML dialplan. However when executing from within an `inline:socket` dialplan the list is different.

        destination ?= call.data.variable_sip_req_user

        ctx = {
          router: this
          cfg: @cfg
          call
          data: call.data
          source
          destination
          req:
            variable: (name) ->
              call.data["variable_#{name}"]
            header: (name) ->
              call.data["variable_sip_h_#{name}"]
          session: {}
          action: (name,args) ->
            call.command name, args
        }
        for own k,v of @session
          ctx.session[k] = v

        it = Promise.resolve()
        for middleware in @middlewares
          do (middleware) =>
            it = it
              .then ->
                debug "middleware `#{middleware.name}`"
                middleware.include.call ctx, ctx
              .catch (error) =>
                debug "middleware `#{middleware.name}` failed", error.toString()
                null

        it
        .catch (error) ->
          debug "route failure", error.toString()
          null
        .then ->
          debug "completed."
          ctx

Toolbox
-------

    pkg = require './package.json'
    Promise = require 'bluebird'
    debug = (require 'debug') "#{pkg.name}:router"
    assert = require 'assert'
