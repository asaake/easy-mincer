Mincer = require("mincer")
path = require("path")
fs = require("fs")
connect = require("connect")
fu = require("./file-util.coffee")
UglifyJS = require("uglify-js")
CleanCSS = require("clean-css")

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
    return dest = {
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