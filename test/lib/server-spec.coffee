require "coffee-script"
require "sugar"

expect = require "expect.js"
path = require "path"
fs = require "../../lib/utils/my-fs"
http = require "http"

Server = require "../../lib/runtimes/server"

describe "Server", () ->

  beforeEach () ->
    @file = path.normalize("#{__dirname}/../easy-mincer.json")
    @server = new Server(@file)

  afterEach (done) ->
    if @server? && @server.isRunning()
      @server.stop () -> done()
    else
      done()

  it "start", (done) ->
    @server.start(() ->
      expect(true).to.ok()
      done()
    )

  it "usePublic", (done) ->
    @server.usePublic()
    @server.start()
    port = @server.config.port
    http.get "http://localhost:#{port}/public.html", (res) =>
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) =>
        expect(chunk).to.eql("<!-- public.html -->")
        done()

  it "useRewrite", (done) ->
    @server.useRewrite()
    @server.usePublic()
    @server.start()
    port = @server.config.port
    http.get "http://localhost:#{port}/rewrite/hello-world/me", (res) =>
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) =>
        expect(chunk).to.eql("<!-- public.html -->")
        done()

  it "useMincer", (done) ->
    @server.useMincer()
    @server.start()
    port = @server.config.port
    http.get "http://localhost:#{port}/assets/main.coffee", (res) =>
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) =>
        #console.log('BODY: ' + chunk)
        expect(chunk).to.eql("""
          (function() {
            var Main;

            Main = (function() {
              function Main() {}

              return Main;

            })();

          }).call(this);
        """)
        done()





