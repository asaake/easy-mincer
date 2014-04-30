Mincer = require "mincer"

module.exports = class RequireEngine extends Mincer.Template

  @defaultMimeType: "application/javascript"

  constructor: () ->
    super

  evaluate: (context) ->
    define = "define"
    name = context.logicalPath
    data = this.data
    index = data.indexOf(define)
    if index != -1
      before = data.substr(0, index)
      data = data.substr(index)
      data = data.substr(define.length) # define ([], function ()... -> ([], function () ...
      data = data.trimLeft() # ([], function () ...
      data = data.substr(1)  # [], function () ...
      data = before + define + "(\"#{name}\", " + data # ("name", [], function () ...
      this.data = data

