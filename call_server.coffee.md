    module.exports = class UsefulWindCallServer
      constructor: (@cfg) ->
        assert @cfg.use, 'Missing cfg.use'
        router = @cfg.router ? new UsefulWindRouter @cfg
        for m in @cfg.use
          do (m) ->
            router.use m
        @server = FS.server ->
          router.route this
        @router = router

      listen: (port) ->
        @init()
        .then =>
          @server.listen port
          debug "#{pkg.name} #{pkg.version}: starting on port #{port}"

Init
----

`init` will fail if any middleware's `init` fails. This allows us to catch misconfigurations early and not start the services if not ready.

      init: (options) ->
        ctx = {
          cfg: @cfg
          options
        }
        it = Promise.resolve()
        for m in @cfg.use
          do (m) =>
            return unless m.init?
            it = it
              .then ->
                m.init.call ctx, ctx
              .catch (error) =>
                debug "middleware `#{mname ? '(no name)'}` init failed", error.toString()
                throw error

        it
        .catch (error) ->
          debug "init failure", error.toString()
          throw error
        .then ->
          debug "init completed."
          ctx

      stop: ->
        new Promise (resolve,reject) =>
          try
            @server.close resolve
            delete @server
          catch exception
            reject exception

    pkg = require './package.json'
    debug = (require 'debug') "#{pkg.name}:call_server"
    UsefulWindRouter = require './router'
    FS = require 'esl'
    assert = require 'assert'
