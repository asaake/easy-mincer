require "coffee-script"
require "../initializer"

path = require "path"
fs = require "../utils/my-fs"
Mincer = require "mincer"
Config = require "../config"

module.exports = class Compiler

  constructor: (config) ->
    if config instanceof Config
      @config = config
    else
      @config = new Config(config)

  clean: () ->
    fs.cleanSync(@config.destDir, false)
    return

  setup: () ->
    unless fs.existsSync(@config.destDir)
      fs.mkdirSync(@config.destDir)
    return

  compile: () ->
    @setup()
    @createDebug()
    @createMinify()
    return

  getDebugDir: () ->
    path.join(@config.destDir, "debug")

  getMinifyDir: () ->
    path.join(@config.destDir, "minify")

  createFiles: (outputDir, options) ->
    files = @config.compile.paths
    environment = @config.createEnvironment(options)

    paths = []
    environment.eachLogicalPath files, (pathname) ->
      paths.push(pathname)

    assetsRootDir = path.join(outputDir, @config.assets.contextRoot)
    paths.forEach (logicalPath) ->
      asset = undefined
      target = undefined
      asset = environment.findAsset(logicalPath, {
        bundle: true
      })
      unless asset
        throw new Error("Can not find asset '" + logicalPath + "'")

      target = path.join(assetsRootDir, logicalPath)
      if fs.existsSync(target)
        console.warn("skip file: #{target}")

      buffer = asset.buffer
      if asset.sourceMap? && options.useSourceMaps?
        fs.outputFileSync "#{target}.map", asset.sourceMap
        buffer = asset.buffer + "\n/*# sourceMappingURL=" + "#{logicalPath}.map */"

      fs.outputFileSync(target, buffer)
      console.info("assets create: " + logicalPath)

    # public
    publicRootDir = path.join(outputDir, @config.public.contextRoot)
    for pubPath in @config.public.paths
      fs.copySync(path.join(@config.workDir, pubPath), publicRootDir)
      console.info("public copy: " + pubPath)

    return

  createDebug: () ->
    @createFiles(@getDebugDir(), {
      useSourceMaps: true
    })

  createMinify: () ->
    @createFiles(@getMinifyDir(), {
      useSourceMaps: true
      jsCompressor: "uglify"
      cssCompressor: "csswring"
    })















