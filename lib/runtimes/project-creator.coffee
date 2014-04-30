require "coffee-script"
require "../initializer"

fs = require "fs"
path = require "path"
fu = require "../utils/file-util"

module.exports = class ProjectCreator

  constructor: (targetDir) ->
    @targetDir = targetDir
    @projectDir = "#{__dirname}/../resources/project"

  create: (process) ->

    if not(fs.existsSync(@targetDir))
      fs.mkdirSync(@targetDir)

    fs.readdirSync(@projectDir).forEach (file) =>
      fu.copySync(path.join(@projectDir, file), path.join(@targetDir, file))

    fs.renameSync("#{@targetDir}/gitignore", "#{@targetDir}/.gitignore")

    fs.readdirSync(@targetDir).forEach (file) =>
      fu.chownSync(path.join(@targetDir, file), process.getuid(), process.getgid())

  clean: () ->
    fu.cleanSync(@targetDir, false)

