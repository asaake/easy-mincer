require "coffee-script"
require "sugar"
require "../initializer"

Mincer = require "mincer"
path = require "path"
fs = require "../utils/my-fs"
Express = require "express"
Minimatch = require "minimatch"
Config = require "../config"

module.exports = class Server

  constructor: (file) ->
    @config = new Config(file)
    @app = Express()

  useRewrite: () ->
    @app.use (req, res, next) =>
      rewriteRoot = @config.serverRoot
      isIgnore = false
      for ignorePath in @config.rewrite.ignorePaths
        isIgnore = Minimatch(req.url, path.join(rewriteRoot, ignorePath))
        if isIgnore
          break

      unless isIgnore
        for rewrite in @config.rewrite.paths
          keys = Object.keys(rewrite)
          rewriteRegex = keys[0]
          rewritePath = rewrite[rewriteRegex]
          isRewrite = Minimatch(req.url, path.join(rewriteRoot, rewriteRegex))
          if isRewrite
            rewritePath = path.join(rewriteRoot, rewritePath)
            Mincer.logger["info"]("rewrite: #{req.url} -> #{rewritePath}")
            req.url = rewritePath
            break

      next()

  usePublic: () ->
    pubRoot = path.join(@config.serverRoot, @config.public.contextRoot)
    for pubPath in @config.public.paths
      pubPath = path.join(@config.workDir, pubPath)
      @app.use(pubRoot, Express.static(pubPath))

  useMincer: () ->
    assetsRoot = path.join(@config.serverRoot, @config.assets.contextRoot)
    server = new Mincer.Server(@config.createEnvironment())
    console.log "assetsRoot: [" + assetsRoot + "]"
    @app.use assetsRoot, (req, res) =>
      server.handle(req, res)

  start: (callback) ->
    @process = @app.listen(@config.port, (err) =>
      if err
        console.error("Failed start server: " + (err.message || err.toString()))
        process.exit(128)

      console.info("Listening on localhost:#{@config.port}")
      console.info()

      if callback? then callback()
    )

  stop: (callback) ->
    if not @isRunning() then throw new Error("not running server.")
    @process.close(callback)
    @process = null

  isRunning: () ->
    @process?

