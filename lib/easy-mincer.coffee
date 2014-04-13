Mincer = require("mincer")
path = require("path")
fs = require("fs")
connect = require("connect")
fu = require("./file-util.coffee")
UglifyJS = require("uglify-js")
CleanCSS = require("clean-css")
minimatch = require("minimatch")

stripLeft = (s, c) ->
  index = 0
  for i in [0..(s.length - 1)]
    if s.charAt(i) != c
      break
    else
      index++

  return s.slice(index)

stripRight = (s, c) ->
  lastIndex = s.length
  for i in [(s.length - 1)..0]
    if s.charAt(i) != c
      break
    else
      lastIndex--

  return s.slice(0, lastIndex)

strip = (s, c) ->
  return stripRight(stripLeft(s, c), c)

absolutePath = (path) ->
  if not(path?)
    return "/"

  path = strip(path, "/")
  return "/#{path}"

log = (level, log) ->
  Mincer.logger[level](log)

module.exports = class EasyMincer

  constructor: (file) ->
    console.info("config: #{file}")
    text = fs.readFileSync(file)
    try
      @config = JSON.parse(text)
    catch e
      throw new Error("#{text} json parse error. to #{e.toString()}")

    @config.port ?= 3000
    @config.serverRoot = absolutePath(@config.serverRoot)
    @config.mainDir = path.dirname(file)
    @config.destDir = @config.mainDir + "/dest"
    @config.manifestDir = @config.mainDir + "/manifest"

    # rewrite
    rewrites = {}
    for rewriteRegex, rewrite of @config.rewrites
      rewrite = "#{@config.serverRoot}#{absolutePath(rewrite)}"
      rewrites[rewriteRegex] = rewrite
      console.info("    rewrite #{rewriteRegex} -> #{rewrite}")
    @config.rewrites = rewrites

    @environment = new Mincer.Environment(@config.mainDir)
    targets = @config.paths
    for target in targets
      @environment.appendPath(target);
      console.info("    appendPath:[#{target}]")

    if @config.useSourceMaps
      @environment.enable("source_maps")

  start: (callback=null) ->
    # logger
    logger = {}
    @config.log ?= {}

    if @config.log.debug
      logger["log"] = console.log
      logger["debug"] = console.log

    if @config.log.info
      logger["info"] = console.info

    if @config.log.warn
      logger["wran"] = console.warn

    if @config.log.error
      logger["error"] = console.error

    Mincer.logger.use(logger)

    @app = connect()
    @app.use (req, res, next) =>
      isAssets = minimatch(req.url, @config.serverRoot + "/**")
      if not(isAssets)
        for rewriteRegex, rewrite of @config.rewrites
          isRewrite = minimatch(req.url, rewriteRegex)
          if isRewrite
            log("info", "rewrite: #{req.url} -> #{rewrite}")
            req.url = rewrite
            break

      next()

    server = new Mincer.Server(@environment)
    @app.use @config.serverRoot, (req, res) ->
      server.handle(req, res)

    @runServer = @app.listen(@config.port, (err) =>
      if err
        console.error("Failed start server: " + (err.message || err.toString()))
        process.exit(128)

      console.info("Listening on localhost:#{@config.port}")
      console.info()

      if callback? then callback()
    )

  stop: (callback) ->
    if not @isRunning() then throw new Error("not running server.")
    @runServer.close(callback)
    @runServer = null

  isRunning: () ->
    @runServer?

  compile: () ->

    fu.cleanSync(@config.destDir, false)
    fu.cleanSync(@config.manifestDir, false)

    assetsData = @_manifest()
    destFiles = @_export(assetsData)

    return {
      destFiles: destFiles
      assetsData: assetsData
    }

  _manifest: () ->
    if not(fs.existsSync(@config.manifestDir))
      fs.mkdirSync(@config.manifestDir)

    manifest = new Mincer.Manifest(@environment, @config.manifestDir)
    try
      assetsData = manifest.compile(@config.targets, {
        compress: true,
        sourceMaps: true,
        embedMappingComments: true
      });

      console.info("""
        Assets were successfully compiled.
        Manifest data (a proper JSON) was written to:
          manifest.path

      """)
      console.dir(assetsData)
      return assetsData
    catch err
      console.error("Failed compile assets: " + (err.message || err.toString()))
      throw err

  _export: (assetsData) ->
    destFiles = []
    if not(fs.existsSync(@config.destDir))
      fs.mkdirSync(@config.destDir)

    for target in @config.targets
      dest = @_dest(assetsData, target)
      minify = @_minify(dest)
      fs.writeFileSync(minify.file, minify.code)
      destFiles.push(dest.file)
      console.info("export #{dest.file}")
      console.info("export #{minify.file}")

    return destFiles

  _dest: (assetsData, target) ->

    if not(assetsData.assets[target]?)
      throw new Error("manifest not export #{target}.")

    file = "#{@config.destDir}/#{target}"
    code = fs.readFileSync("#{@config.manifestDir}/#{assetsData.assets[target]}")
    fs.writeFileSync(file, code)
    return {
      file: file
      code: code
    }

  _minify: (dest) ->
    extIndex = dest.file.lastIndexOf(".")
    ext = dest.file.slice(extIndex + 1)
    writeFile = dest.file.slice(0, extIndex) + ".min." + ext
    code = null
    switch ext
      when "js"
        code = @_minifyJS(dest.file)
      when "css"
        code = @_minifyCSS(dest.file)
      else
        throw new Error("Failed minify compile #{writeFile} file has not extension.")

    return {
      file: writeFile
      code: code
    }

  _minifyJS: (readFile) ->
    UglifyJS.minify(readFile).code

  _minifyCSS: (readFile) ->
    new CleanCSS().minify(fs.readFileSync(readFile))