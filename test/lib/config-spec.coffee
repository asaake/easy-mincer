expect = require "expect.js"
path = require "path"
Config = require "../../lib/config"

describe "Config", () ->

  describe "設定をオブジェクトで読み込む", () ->

    it "workDirがない場合はエラーが発生する", () ->
      try
        new Config({})
        fial("don't error")
      catch e
        expect(e.message).to.eql("config.workDir is required.")


    it "readConfig: ファイル名を指定して設定を読み込める", () ->
      workDir = path.join(__dirname, "..")
      file = path.join(workDir, "easy-mincer.json")
      config = new Config(file)

      expect(config.workDir).to.eql(workDir)
      expect(config.destDir).to.eql(path.join(workDir, "dest"))

      expect(config.port).to.eql(3000)
      expect(config.serverRoot).to.eql("/")

      # assets
      expect(config.assets.contextRoot).to.eql("/assets")
      expect(config.assets.paths).to.eql([
        "app/assets/javascripts"
        "app/assets/stylesheets"
        "app/assets/templates"
      ])
      expect(config.assets.useSourceMaps).to.eql(false)

      # public
      expect(config.public.contextRoot).to.eql("/")
      expect(config.public.paths).to.eql([
        "app/public/javascripts"
        "app/public/stylesheets"
        "app/public/templates"
      ])

      # rewrite
      expect(config.rewrite.paths).to.eql([{
        "/rewrite/**": "/public.html"
      }])
      expect(config.rewrite.ignorePaths).to.eql([
        "/assets/**"
      ])

      expect(config.log).to.eql({
          "debug": false,
          "info": true,
          "warn": true,
          "error": true
      })

      expect(config.compile.paths).to.eql(["main.js", "main.css", "nest/main.js"])

    it "createEnvironment: 設定に従ってEnvironmentオブジェクトを作成できる", () ->

      workDir = path.join(__dirname, "..")
      file = path.join(workDir, "easy-mincer.json")
      config = new Config(file)

      environment = config.createEnvironment()
      expect(environment.root).to.eql(config.workDir)
      expect(environment.paths).to.eql([
        "#{config.workDir}/app/assets/javascripts"
        "#{config.workDir}/app/assets/stylesheets"
        "#{config.workDir}/app/assets/templates"
      ])
      expect(environment.isEnabled("source_maps")).to.eql(false)
