Mincer = require("mincer")
path = require("path")
fs = require("fs")
connect = require("connect")
fu = require("./file-util.coffee")

module.exports = class EasyMincer

  constructor: (file) ->
    console.log("config: #{file}")
    @config = require(file)
    @config.mainDir = path.dirname(file)
    @config.destDir = @config.mainDir + "/dest"
    @config.manifestDir = @config.mainDir + "/manifest"

    @environment = new Mincer.Environment(@config.mainDir)
    targets = @config.paths
    for target in targets
      @environment.appendPath(target);
      console.log("    appendPath:[#{target}]")

  start: () ->
    @app = connect()
    @app.use("/", Mincer.createServer(@environment))
    @app.listen(3000, (err) ->
      if err
        console.error("Failed start server: " + (err.message || err.toString()));
        process.exit(128)

      console.info("Listening on localhost:3000");
    )

  compile: () ->

    fu.clean(@config.destDir, false)
    fu.clean(@config.manifestDir, false)

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
      readFile = assetsData.assets[target]
      if readFile?
        writeFile = "#{@config.destDir}/#{target}"
        readFile = "#{@config.manifestDir}/#{readFile}"
        fs = require("fs")
        fs.writeFileSync(writeFile, fs.readFileSync(readFile))
        destFiles.push(writeFile)
        console.info("export #{writeFile}")

    return destFiles