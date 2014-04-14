expect = require "expect.js"
Server = require "../../lib/server"
Path = require "path"
Fs = require "fs"
Http = require "http"

describe "Server", () ->

  beforeEach () ->
    @file = Path.normalize("#{__dirname}/../easy-mincer.json")
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
    Http.get "http://localhost:#{port}/assets/public.html", (res) =>
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
    Http.get "http://localhost:#{port}/hello-world/me", (res) =>
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) =>
        expect(chunk).to.eql("<!-- public.html -->")
        done()

  it "useMincer", (done) ->
    @server.useMincer()
    @server.start()
    port = @server.config.port
    Http.get "http://localhost:#{port}/assets/main.coffee", (res) =>
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





