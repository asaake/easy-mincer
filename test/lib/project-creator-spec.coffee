expect = require("expect.js")
path = require("path")
fs = require("fs")

describe "ProjectCreator", () ->

  it "create", () ->
    ProjectCreator = require("../../lib/project-creator.coffee")
    dir = path.resolve("#{__dirname}/../work")
    creator = new ProjectCreator(dir)

    creator.clean()
    expect(fs.existsSync("#{dir}/README.md")).to.eql(false)

    creator.create()
    expect(fs.existsSync("#{dir}/README.md")).to.eql(true)
