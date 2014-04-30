require "coffee-script"
require "../initializer"

Mincer = require "mincer"
Path = require "path"
Fs = require "fs"
Express = require "express"
Minimatch = require "minimatch"
FileUtil = require "../utils/file-util"
Config = require "../config"

module.exports = class Server

  constructor: (file) ->
    @config = new Config(file)
    @app = Express()

  useRewrite: () ->
    @app.use (req, res, next) =>
      isAssets = Minimatch(req.url, @config.serverRoot + "/**")
      if not(isAssets)
        for rewriteRegex, rewrite of @config.rewrites
          isRewrite = Minimatch(req.url, rewriteRegex)
          if isRewrite
            Mincer.logger["info"]("rewrite: #{req.url} -> #{rewrite}")
            req.url = rewrite
            break

      next()

  usePublic: () ->
    for publicPath in @config.publicPaths
      @app.use(@config.serverRoot, Express.static(publicPath))

  useMincer: () ->
    server = new Mincer.Server(@config.environment)
    @app.use @config.serverRoot, (req, res) =>
      server.handle(req, res)

  start: (callback) ->

    @appProcess = @app.listen(@config.port, (err) =>
      if err
        console.error("Failed start server: " + (err.message || err.toString()))
        process.exit(128)

      console.info("Listening on localhost:#{@config.port}")
      console.info()

      if callback? then callback()
    )

  stop: (callback) ->
    if not @isRunning() then throw new Error("not running server.")
    @appProcess.close(callback)
    @appProcess = null

  isRunning: () ->
    @appProcess?

