expect = require "expect.js"
Server = require "../../lib/runtimes/server"
path = require "path"
http = require "http"

describe "Server", () ->

  beforeEach (done) ->
    @file = path.normalize("#{__dirname}/../easy-mincer.json")
    @server = new Server(@file)
    @server.useMincer()
    @server.start(() ->
      expect(true).to.ok()
      done()
    )

  afterEach (done) ->
    if @server? && @server.isRunning()
      @server.stop () -> done()
    else
      done()

  it "compileAmdFile", (done) ->
    port = @server.config.port
    http.get "http://localhost:#{port}/assets/amd.js", (res) =>
      expect(res.statusCode).to.eql(200)
      res.setEncoding("utf8")
      res.on "data", (chunk) =>
        #console.log('BODY: ' + chunk)
        expect(chunk).to.eql("""
          (function() {
            define("amd", [], function() {
              var Amd;
              return Amd = (function() {
                function Amd() {}

                return Amd;

              })();
            });

          }).call(this);
        """)
        done()





