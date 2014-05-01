require "coffee-script"
require "../initializer"

fs = require "../utils/my-fs"
path = require "path"

module.exports = class ProjectCreator

  constructor: (targetDir) ->
    @targetDir = targetDir
    @projectDir = "#{__dirname}/../resources/project"

  create: (process) ->

    if not(fs.existsSync(@targetDir))
      fs.mkdirSync(@targetDir)

    fs.readdirSync(@projectDir).forEach (file) =>
      fs.copySync(path.join(@projectDir, file), path.join(@targetDir, file))

    fs.renameSync("#{@targetDir}/gitignore", "#{@targetDir}/.gitignore")

    fs.readdirSync(@targetDir).forEach (file) =>
      fs.chownRSync(path.join(@targetDir, file), process.getuid(), process.getgid())

  clean: () ->
    fs.cleanSync(@targetDir, false)

