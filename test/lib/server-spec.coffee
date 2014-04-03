expect = require("expect.js")
http = require("http")

describe "Server", () ->

  it "readCoffeeFile", (done) ->
    app = require("../../lib/server.coffee")
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

