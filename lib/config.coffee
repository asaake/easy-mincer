require "coffee-script"
require "sugar"

Mincer = require "mincer"
fs = require "./utils/my-fs"
path = require "path"

module.exports = class Config

  @readConfigFile: (file) ->
    try
      console.info("read config: #{file}")
      text = fs.readFileSync(file)
      config = JSON.parse(text)
      config.workDir = path.dirname(file)
      return config
    catch e
      throw new Error("#{text} json parse error. to #{e.toString()}")

  constructor: (options) ->

    if typeof options == "string"
      config = Config.readConfigFile(options)
    else
      config = options

    config = @mergeDefault(config)
    config = @setup(config)

    # setup logger
    @setupLogger(config)

    # copy config
    for key, value of config
      @[key] = value
    @_config = config

  setup: (config) ->
    config.serverRoot = path.normalize(config.serverRoot)
    config.workDir = path.normalize(config.workDir)
    config.destDir = path.join(config.workDir, "dest")

    config

  mergeDefault: (config) ->

    if not(config.workDir?)
      throw new Error("config.workDir is required.")

    defaultConfig = {
      port: 3000
      serverRoot: "/"
      assets: {
        useSourceMaps: false
        contextRoot: "/"
        paths: []
      }
      public: {
        contextRoot: "/"
        paths: []
      }
      rewrite: {
        paths: []
        ignorePaths: []
      }
      log: {
        debug: false
        info: true
        warn: true
        error: true
      }
      compile: {
        paths: []
      }
    }

    clone = Object.clone(defaultConfig, true)
    Object.merge(clone, config, true)

  createEnvironment: (options={}) ->
    environment = new Mincer.Environment(@workDir)
    for assetsPath in @assets.paths
      environment.appendPath(assetsPath)

    if @assets.useSourceMaps || options.useSourceMaps
      environment.enable("source_maps")

    if options.jsCompressor?
      environment.jsCompressor = options.jsCompressor

    if options.cssCompressor?
      environment.cssCompressor = options.cssCompressor

    return environment

  setupLogger: (config) ->
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

