expect = require("expect.js")
Path = require "path"
Config = require "../../lib/config"

describe "Config", () ->

  describe "設定をオブジェクトで読み込む", () ->

    it "mainDirがない場合はエラーが発生する", () ->
      try
        new Config({})
        fial("don't error")
      catch e
        expect(e.message).to.eql("config.mainDir is required.")

    it "読み込み", () ->
      root = Path.join(__dirname, "..")
      options = {
        mainDir: root
      }
      config = new Config(options)
      expect(config.port).to.eql(3000)
      expect(config.serverRoot).to.eql("/")
      expect(config.targets).to.eql([])
      expect(config.paths).to.eql([])
      expect(config.publicPaths).to.eql([])
      expect(config.rewrites).to.eql({})
      expect(config.log).to.eql({
        "debug": false,
        "info": false,
        "warn": true,
        "error": true
      })
      expect(config.useSourceMaps).to.eql(false)

      # environment
      environment = config.environment
      expect(environment.root).to.eql(root)
      expect(environment.paths).to.eql([])

  it "設定をファイルで読み込む", () ->
    root = Path.join(__dirname, "..")
    config = new Config(Path.join(root, "easy-mincer.json"))
    expect(config.port).to.eql(3000)
    expect(config.serverRoot).to.eql("/assets")
    expect(config.targets).to.eql(["main.js", "main.css"])
    expect(config.paths).to.eql([
      "app/assets/javascripts"
      "app/assets/stylesheets"
      "app/assets/templates"
    ])
    expect(config.publicPaths).to.eql([
      "#{root}/app/public/javascripts"
      "#{root}/app/public/stylesheets"
      "#{root}/app/public/templates"
    ])
    expect(config.rewrites).to.eql({
      "/**": "/assets/public.html"
    })
    expect(config.log).to.eql({
        "debug": false,
        "info": false,
        "warn": true,
        "error": true
    })
    expect(config.useSourceMaps).to.eql(false)

    # environment
    environment = config.environment
    expect(environment.root).to.eql(root)
    expect(environment.paths).to.eql([
      "#{root}/app/assets/javascripts"
      "#{root}/app/assets/stylesheets"
      "#{root}/app/assets/templates"
    ])

    # generate config
    expect(config.manifestDir).to.eql(Path.join(root, "manifest"))
    expect(config.destDir).to.eql(Path.join(root, "dest"))