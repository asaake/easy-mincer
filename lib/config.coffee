Mincer = require "mincer"
Fs = require "fs"
Path = require "path"

module.exports = class Config

  @readConfigFile: (file) ->
    try
      console.info("config: #{file}")
      text = Fs.readFileSync(file)
      config = JSON.parse(text)
      config.mainDir = Path.dirname(file)
      return config
    catch e
      throw new Error("#{text} json parse error. to #{e.toString()}")

  constructor: (options) ->

    if typeof options == "string"
      config = Config.readConfigFile(options)
    else
      config = options

    @setUpDefault(config)
    config.rewrites = @createRewrites(config)
    config.publicPaths = @createPublicPaths(config)
    config.environment = @createEnvironment(config)

    # copy config
    for key, value of config
      @[key] = value

    # logger
    logger = {}
    config.log ?= {}
    if config.log.debug
      logger["log"] = console.log
      logger["debug"] = console.log

    if config.log.info
      logger["info"] = console.info

    if config.log.warn
      logger["wran"] = console.warn

    if config.log.error
      logger["error"] = console.error

    Mincer.logger.use(logger)
    @readConfig = config

  setUpDefault: (config) ->

    if not(config.mainDir?)
      throw new Error("config.mainDir is required.")

    # default
    config.port ?= 3000
    config.serverRoot ?= "/"
    config.targets ?= []
    config.paths ?= []
    config.publicPaths ?= []
    config.rewrites ?= []
    config.log ?= {
      debug: false
      info: false
      warn: true
      error: true
    }
    config.useSourceMaps ?= false
    config.useJsCompressor ?= false
    config.useCssCompressor ?= false

    # setup
    config.serverRoot = Path.normalize(config.serverRoot)
    config.destDir = Path.join(config.mainDir, "/dest")
    config.manifestDir = Path.join(config.mainDir, "/manifest")

  createRewrites: (config) ->
    rewrites = {}
    for rewriteRegex, rewrite of config.rewrites
      rewrite = Path.join(config.serverRoot, rewrite)
      rewrites[rewriteRegex] = rewrite
      console.info("rewrite path: #{rewriteRegex} -> #{rewrite}")
    return rewrites

  createPublicPaths: (config) ->
    publicPaths = []
    for publicPath in config.publicPaths
      path = Path.join(config.mainDir, publicPath)
      publicPaths.push(Path.join(config.mainDir, publicPath))
      console.info("public path: #{path}")
    return publicPaths

  createEnvironment: (config) ->
    environment = new Mincer.Environment(config.mainDir)
    for path in config.paths
      environment.appendPath(path);
      console.info("assets path: #{path}")

    if config.useSourceMaps
      environment.enable("source_maps")

    if config.useJsCompressor
      environment.jsCompressor = "uglify"

    if config.useCssCompressor
      environment.cssCompressor = "csswring"

    return environment

