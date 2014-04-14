require "sugar"

expect = require "expect.js"
Path = require "path"
Fs = require "fs"
Config = require "../../lib/config"
Compiler = require "../../lib/compiler"

describe "Compiler", () ->

  before () ->
    @root = Path.join(__dirname, "..")
    @config = {
      "mainDir": @root
      "serverRoot": "/assets"
      "targets": ["main.js", "main.css"]
      "paths": [
        "app/assets/javascripts"
        "app/assets/stylesheets"
        "app/assets/templates"
      ],
      "useSourceMaps": false
    }

  it "clean dest, manifestフォルダ以下が削除される", () ->
    config = new Config(@config)
    compiler = new Compiler(config)

    Fs.writeFileSync(Path.join(config.manifestDir, "blank", ""))
    Fs.writeFileSync(Path.join(config.destDir, "blank", ""))
    expect(Fs.readdirSync(config.manifestDir).length).to.greaterThan(0)
    expect(Fs.readdirSync(config.destDir).length).to.greaterThan(0)

    compiler.clean()
    expect(Fs.readdirSync(config.manifestDir).length).to.eql(0)
    expect(Fs.readdirSync(config.destDir).length).to.eql(0)

  describe "毎回cleanを実行する", () ->

    beforeEach () ->
      compiler = new Compiler(@config)
      compiler.clean()

      @mainMinJs = "(function(){var n;n=function(){function n(){}return n}()}).call(this);"
      @mainMinCss = ".p{color:#f938ab}"
      @mainJs = """
        (function() {
          var Main;

          Main = (function() {
            function Main() {}

            return Main;

          })();

        }).call(this);
      """
      @mainCss = """
        .p {
          color: #f938ab;
        }

      """

    it "createManifest minされたmanifestファイルが作成される", () ->
      config = Object.clone(@config, true)
      config.useSourceMaps = true
      config.useJsCompressor = true
      config.useCssCompressor = true

      config = new Config(config)
      compiler = new Compiler(config)
      result = compiler.createManifest()

      # min js
      srcJs = Fs.readFileSync(Path.join(config.manifestDir, result.assets["main.js"]), "utf8")
      minJs = @mainMinJs + "\n//# sourceMappingURL=#{result.assets["main.js"]}.map"
      expect(srcJs).to.eql(minJs)

      # min css
      srcCss = Fs.readFileSync(Path.join(config.manifestDir, result.assets["main.css"]), "utf8")
      minCss = @mainMinCss + "\n/*# sourceMappingURL=#{result.assets["main.css"]}.map */"
      expect(srcCss).to.eql(minCss)

    it "createManifest minされていないmanifestファイルが作成される", () ->
      config = Object.clone(@config, true)
      config.useSourceMaps = true
      config.useJsCompressor = false
      config.useCssCompressor = false

      config = new Config(config)
      compiler = new Compiler(config)
      result = compiler.createManifest()

      # js
      srcJs = Fs.readFileSync(Path.join(config.manifestDir, result.assets["main.js"]), "utf8")
      minJs = @mainJs + "\n//# sourceMappingURL=#{result.assets["main.js"]}.map"
      expect(srcJs).to.eql(minJs)

      # css
      srcCss = Fs.readFileSync(Path.join(config.manifestDir, result.assets["main.css"]), "utf8")
      minCss = @mainCss + "\n/*# sourceMappingURL=#{result.assets["main.css"]}.map */"
      expect(srcCss).to.eql(minCss)

    it "createDestFiles manifestフォルダをすべてdestフォルダに書き込む", () ->
      config = Object.clone(@config, true)
      config.useSourceMaps = true
      config.useJsCompressor = false
      config.useCssCompressor = false

      config = new Config(config)
      compiler = new Compiler(config)
      result = compiler.createManifest()

      compiler.exportDestFiles()

      for file, fingerprintFile of result.assets
        path = Path.join(@config.destDir, file)
        expect(Fs.existsSync(path)).to.eql(true)



