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
    mainJs = """
      var Main;

      Main = (function() {
        function Main() {}

        return Main;

      })();
    """
    mainMinJs = "var Main;Main=function(){function n(){}return n}();"

    mainCss = """
      .p {
        color: #f938ab;
      }

    """
    mainMinCss = ".p{color:#f938ab}"

    dir = path.dirname(@file)
    result = @easyMincer.compile()

    # manifest js
    manifestFile = path.resolve("#{dir}/manifest/" + result.assetsData.assets["main.js"])
    src = fs.readFileSync(manifestFile, "utf8")
    expect(src).to.eql(mainJs)

    # dest js
    destFile = path.resolve("#{dir}/dest/main.js")
    src = fs.readFileSync(destFile, "utf8")
    expect(src).to.eql(mainJs)

    # dest min js
    destMinFile = path.resolve("#{dir}/dest/main.min.js")
    src = fs.readFileSync(destMinFile, "utf8")
    expect(src).to.eql(mainMinJs)

    # manifest css
    manifestFile = path.resolve("#{dir}/manifest/" + result.assetsData.assets["main.css"])
    src = fs.readFileSync(manifestFile, "utf8")
    expect(src).to.eql(mainCss)

    # dest css
    destFile = path.resolve("#{dir}/dest/main.css")
    src = fs.readFileSync(destFile, "utf8")
    expect(src).to.eql(mainCss)

    # dest min css
    destMinFile = path.resolve("#{dir}/dest/main.min.css")
    src = fs.readFileSync(destMinFile, "utf8")
    expect(src).to.eql(mainMinCss)

  it "start", (done) ->
    @easyMincer.start()
    http.get "http://localhost:3000/assets/main.coffee", (res) ->
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


