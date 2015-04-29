    module.exports = class UsefulWindCallServer
      constructor: (@cfg) ->
        router = @cfg.router ? new UsefulWindRouter @cfg
        if @cfg.use?
          for m in @cfg.use
            do (m) ->
              router.use m
        @server = FS.server ->
          router.route this
        @router = router

      listen: (port) ->
        @router.init()
        .then =>
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
    debug = (require 'debug') "#{pkg.name}:call_server"
    UsefulWindRouter = require './router'
    FS = require 'esl'
