    module.exports = class UsefulWindCallServer
      constructor: (@cfg) ->
        debug 'constructor'
        assert @cfg.use?, 'Missing cfg.use'
        @router = @cfg.router ? new UsefulWindRouter @cfg
        for m in @cfg.use
          @router.use m
        return

      listen: (port) ->
        router = @router
        serialize @cfg, 'init'
        .then =>
          @server = FS.server ->
            router
            .route this
            .catch (error) ->
              debug.dev "Router Failure", error.stack ? JSON.stringify error
            return
          @server.listen port
          debug "#{pkg.name} #{pkg.version}: starting on port #{port}"
          return

      stop: ->
        serialize @cfg, 'end'
        .then =>
          server = @server
          delete @server
          new Promise (resolve,reject) ->
            server.close (err) -> if err then reject err else resolve()
            return

    pkg = require './package.json'
    debug = (require 'tangible') "#{pkg.name}:call_server"
    UsefulWindRouter = require './router'
    FS = require 'esl'
    assert = require 'assert'
    serialize = require 'useful-wind-serialize'
