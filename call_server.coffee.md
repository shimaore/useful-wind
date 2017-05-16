    module.exports = class UsefulWindCallServer
      constructor: (@cfg) ->
        debug 'constructor'
        assert @cfg.use?, 'Missing cfg.use'
        @router = @cfg.router ? new UsefulWindRouter @cfg
        for m in @cfg.use
          @router.use m

      listen: (port) ->
        router = @router
        serialize @cfg, 'init'
        .then =>
          @server = FS.server ->
            router.route this
          @server.listen port
          debug "#{pkg.name} #{pkg.version}: starting on port #{port}"

      stop: ->
        new Promise (resolve,reject) =>
          try
            @server.close resolve
            delete @server
          catch exception
            reject exception

    pkg = require './package.json'
    debug = (require 'tangible') "#{pkg.name}:call_server"
    UsefulWindRouter = require './router'
    FS = require 'esl'
    assert = require 'assert'
    serialize = require 'useful-wind-serialize'
