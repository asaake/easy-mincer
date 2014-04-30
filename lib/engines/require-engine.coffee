Mincer = require "mincer"

module.exports = class RequireEngine extends Mincer.Template

  @defaultMimeType: "application/javascript"

  constructor: () ->
    super
    @define = "define"
    @defineMatcher = new RegExp("^#{@define}")

    @bare = "\\(function\\(\\) {"
    @bareMatcher = new RegExp("^#{@bare}")

  evaluate: (context) ->
    name = context.logicalPath
    data = this.data
    isBare = false
    if @bareMatcher.test(data)
      isBare = true
      data = data.substr(@bare.length).trimLeft()

    if @defineMatcher.test(data)
      data = data.substr(@define.length) # define ([], function ()... -> ([], function () ...
      data = data.trimLeft() # ([], function () ...
      data = data.substr(1)  # [], function () ...
      data = @define + "(\"#{name}\", " + data # ("name", [], function () ...
      if isBare
        data = "(function () {\n  " + data
      this.data = data

