Serialize calling the middleware function `name` in `cfg.use`.

    serialize = (cfg,name) ->

      ctx = {cfg}
      it = Promise.resolve()
      if cfg.use?

FIXME: replace with Promise.all() ??

        for m in cfg.use when m[name]?
          do (m) ->
            it = it.then ->
              debug "Calling middleware #{m.name}.#{name}()"
              m[name].call ctx, ctx
              null

      it

    Promise = require 'bluebird'
    pkg = require './package.json'
    debug = (require 'debug') "#{pkg.name}:serialize"
    module.exports = serialize
