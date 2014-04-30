require "coffee-script"
require "../initializer"

Mincer = require "mincer"
Path = require "path"
Fs = require "fs-extra"
FileUtil = require "../utils/file-util"
Config = require "../config"

module.exports = class Compiler

  constructor: (config) ->
    if config instanceof Config
      @config = config
    else
      @config = new Config(config)

  clean: () ->
    FileUtil.cleanSync(@config.destDir, false)
    FileUtil.cleanSync(@config.manifestDir, false)

  createManifest: () ->
    # create export manifest folder
    if not(Fs.existsSync(@config.manifestDir))
      Fs.mkdirSync(@config.manifestDir)

    environment = @config.environment
    manifest = new Mincer.Manifest(environment, @config.manifestDir)
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

  exportDestFiles: () ->

    if not(Fs.existsSync(@config.destDir))
      Fs.mkdirSync(@config.destDir)

    # manifest files copy
    destFiles = []
    files = Fs.readdirSync(@config.manifestDir)
    files.forEach (file) =>
      h = file.lastIndexOf("-")
      if h != -1
        p = file.indexOf(".", h)
        destFile = file.slice(0, h) + file.slice(p)
        dest = Path.join(@config.destDir, destFile)
        src = Path.join(@config.manifestDir, file)

        Fs.copySync(src, dest)
        destFiles.push(file)
        console.info("export #{file} -> #{destFile}")

    return destFiles

