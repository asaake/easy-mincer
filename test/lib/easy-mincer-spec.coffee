expect = require("expect.js")
EasyMincer = require "../../lib/easy-mincer.coffee"
path = require("path")
fs = require("fs")
http = require("http")

describe "EasyMincer", () ->

  beforeEach () ->
    @file = path.resolve("#{__dirname}/../easy-mincer.json")
    @easyMincer = new EasyMincer(@file)

  it "readConfig", () ->
    config = @easyMincer.config
    environment = @easyMincer.environment

    dir = path.dirname(@file)
    expect(config.mainDir).to.eql(dir)
    expect(environment.paths[0]).to.eql("#{dir}/app/assets/javascripts")

  it "compile", () ->
    mainSrc = """
      var Main;

      Main = (function() {
        function Main() {}

        return Main;

      })();
    """

    dir = path.dirname(@file)
    result = @easyMincer.compile()

    manifestFile = path.resolve("#{dir}/manifest/" + result.assetsData.assets["main.js"])
    src = fs.readFileSync(manifestFile, "utf8")
    expect(src).to.eql(mainSrc)

    destFile = path.resolve("#{dir}/dest/main.js")
    src = fs.readFileSync(destFile, "utf8")
    expect(src).to.eql(mainSrc)

  it "start", (done) ->
    @easyMincer.start()
    http.get "http://localhost:3000/main.coffee", (res) ->
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) ->
        #console.log('BODY: ' + chunk)
        expect(chunk).to.eql("""
          var Main;

          Main = (function() {
            function Main() {}

            return Main;

          })();
        """)
        done()


