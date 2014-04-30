Mincer = require "mincer"

module.exports = class RequireEngine extends Mincer.Template

  @defaultMimeType: "application/javascript"

  constructor: () ->
    super

  evaluate: (context) ->
    context.logicalPath
    this.data = """
      defineName(#{context.logicalPath}, function () {
      #{this.data}
      });
    """

