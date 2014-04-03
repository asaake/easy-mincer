Mincer = require("mincer")
connect = require("connect")
environment = require("./config.coffee").environment

app = connect()
app.use("/", Mincer.createServer(environment))
app.listen(3000, (err) ->
  if err
    console.error("Failed start server: " + (err.message || err.toString()));
    process.exit(128)

  console.info("Listening on localhost:3000");
)

exports.module = app
