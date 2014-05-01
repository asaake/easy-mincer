expect = require "expect.js"
path = require "path"
fs = require "../../lib/utils/my-fs"

describe "ProjectCreator", () ->

  it "create", () ->
    ProjectCreator = require("../../lib/runtimes/project-creator.coffee")
    dir = path.resolve("#{__dirname}/../work")
    creator = new ProjectCreator(dir)

    creator.clean()
    expect(fs.existsSync("#{dir}/README.md")).to.eql(false)

    creator.create(process)
    expect(fs.existsSync("#{dir}/README.md")).to.eql(true)
    expect(fs.existsSync("#{dir}/gitignore")).to.eql(false)
    expect(fs.existsSync("#{dir}/.gitignore")).to.eql(true)

    stats = fs.statSync("#{dir}/.gitignore")
    expect(stats.uid).to.eql(process.getuid())
    expect(stats.gid).to.eql(process.getgid())

