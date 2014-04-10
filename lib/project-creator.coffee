fs = require("fs")
path = require("path")
fu = require("./file-util.coffee")

module.exports = class ProjectCreator

  constructor: (targetDir) ->
    @targetDir = targetDir
    @projectDir = "#{__dirname}/project"

  create: (process) ->

    if not(fs.existsSync(@targetDir))
      fs.mkdirSync(@targetDir)

    fs.readdirSync(@projectDir).forEach (file) =>
      fu.copySync(path.join(@projectDir, file), path.join(@targetDir, file))

    fs.renameSync("#{@targetDir}/gitignore", "#{@targetDir}/.gitignore")

    fs.readdirSync(@targetDir).forEach (file) =>
      fu.chownSync(path.join(@targetDir, file), process.getuid(), process.getgid())

    fs.rename("#{@targetDir}/gitignore", "#{@targetDir}/.gitignore")

  clean: () ->
    fu.cleanSync(@targetDir, false)

