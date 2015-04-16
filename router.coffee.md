    module.name = 'UsefulWindRouter'
    module.exports = class UsefulWindRouter
      constructor: (@cfg = {}) ->
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

        assert middleware.include?, 'Missing middleware include', middleware
        assert (typeof middleware.include is 'function'), 'Middleware include must be a function'

Add the middleware for in-call use.

        @middlewares.push middleware

      route: (call) ->
        source = call.data['Channel-Caller-ID-Number']
        destination = call.data['Channel-Destination-Number']

        ctx = {
          router: this
          cfg: @cfg
          call
          data: call.data
          source
          destination
          req:
            header: (name) ->
              call.data["variable_sip_h_#{name}"]
          session: {}
          action: (name,args) ->
            call.command name, args
        }
        for own k,v of @session
          ctx.session[k] = v

        it = Promise.resolve()
        it = it.bind ctx
        for middleware in @middlewares
          do (middleware) =>
            it = it
              .then ->
                middleware.include.call ctx, ctx
              .catch (error) =>
                debug "#{module.name} #{pkg.name} #{pkg.version}: middleware #{middleware.name ? '(no name)'} failed", error.toString()
                null

        it
        .catch (error) ->
          debug "#{module.name} #{pkg.name} #{pkg.version}: route failure", error.toString()
          null
        .then ->
          debug "#{module.name} #{pkg.name} #{pkg.version}: completed."
          ctx

Toolbox
-------

    pkg = require './package.json'
    Promise = require 'bluebird'
    debug = (require 'debug') "#{pkg.name}:router"
    assert = require 'assert'
