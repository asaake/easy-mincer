expect = require("expect.js")

describe "Compile", () ->

  it "compile", () ->
    require("../../lib/compile.coffee")
    fs = require("fs")
    path = require("path")
    file = path.resolve("#{__dirname}/../dest/main.js")
    src = fs.readFileSync(file, "utf8")
    expect(src).to.eql("""
      var Main;

      Main = (function() {
        function Main() {}

        return Main;

      })();
    """)