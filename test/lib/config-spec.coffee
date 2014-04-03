expect = require("expect.js")

describe "Config", () ->

  it "readConfig", () ->
    config = require("../../lib/config.coffee")
    expect(config.cwd).to.eql("#{process.cwd()}/test")
    expect(config.environment.paths[0]).to.eql("#{config.cwd}/app/assets/javascripts")


