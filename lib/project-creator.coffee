fs = require("fs")
path = require("path")
fu = require("./file-util.coffee")

module.exports = class ProjectCreator

  constructor: (targetDir) ->
    @targetDir = targetDir
    @projectDir = "#{__dirname}/project"

  create: () ->
    if not(fs.existsSync(@targetDir))
      fs.mkdirSync(@targetDir)

    fs.readdirSync(@projectDir).forEach (file) =>
      fu.copy(path.join(@projectDir, file), path.join(@targetDir, file))

  clean: () ->
    fu.clean(@targetDir, false)

