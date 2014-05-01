require "sugar"

expect = require "expect.js"
path = require "path"
fs = require "../../lib/utils/my-fs"
Config = require "../../lib/config"
Compiler = require "../../lib/runtimes/compiler"

describe "Compiler", () ->

  before () ->
    @config = new Config({
      "workDir": path.join(__dirname, "..")
      "serverRoot": "/"
      "assets": {
        "contextRoot": "/assets"
        "paths": [
          "app/assets/javascripts"
          "app/assets/stylesheets"
          "app/assets/templates"
        ]
        "useSourceMaps": true
      }
      "public": {
        "contextRoot": "/"
        "paths": [
          "app/public/javascripts"
          "app/public/stylesheets"
          "app/public/templates"
        ]
      }
      "compile": {
        paths: ["main.js", "main.css", "nest/main.js"]
      }
    })

  it "clean destフォルダ以下が削除される", () ->
    compiler = new Compiler(@config)

    fs.createFileSync(path.join(@config.destDir, "blank", ""))
    expect(fs.readdirSync(@config.destDir).length).to.greaterThan(0)

    compiler.clean()
    expect(fs.readdirSync(@config.destDir).length).to.eql(0)

  describe "毎回cleanを実行する", () ->

    beforeEach () ->
      compiler = new Compiler(@config)
      compiler.clean()

      @mainMinJs = """
        (function(){var n;n=function(){function n(){}return n}()}).call(this);
        /*# sourceMappingURL=main.js.map */
      """
      @mainMinCss = """
        .p{color:#f938ab}
        /*# sourceMappingURL=main.css.map */
      """
      @mainJs = """
        (function() {
          var Main;

          Main = (function() {
            function Main() {}

            return Main;

          })();

        }).call(this);
        /*# sourceMappingURL=main.js.map */
      """
      @mainCss = """
        .p {
          color: #f938ab;
        }

        /*# sourceMappingURL=main.css.map */
      """
      @publicHtml = """
        <!-- public.html -->
      """

    it "compile: destフォルダに, debug, minify, でpublicおよびassetsの結果を出力する", () ->
      compiler = new Compiler(@config)
      compiler.compile()

      # debug
      debugDir = compiler.getDebugDir()
      assetsRootDir = path.join(debugDir, @config.assets.contextRoot)
      publicRootDir = path.join(debugDir, @config.public.contextRoot)

      # JSおよびSourceMapが存在する
      js = fs.readFileSync(path.join(assetsRootDir, "main.js"), "utf-8")
      expect(js).to.eql(@mainJs)
      expect(fs.existsSync(path.join(assetsRootDir, "main.js.map"))).to.eql(true)

      # CSSおよびSourceMapが存在する
      css = fs.readFileSync(path.join(assetsRootDir, "main.css"), "utf-8")
      expect(css).to.eql(@mainCss)
      expect(fs.existsSync(path.join(assetsRootDir, "main.css.map"))).to.eql(true)

      # Publicのファイルが存在する
      html = fs.readFileSync(path.join(publicRootDir, "public.html"), "utf-8")
      expect(html).to.eql(@publicHtml)

      # ネストしたファイルが存在する
      expect(fs.existsSync(path.join(assetsRootDir, "nest", "main.js"))).to.eql(true)
      expect(fs.existsSync(path.join(publicRootDir, "nest", "nest.html"))).to.eql(true)

      # minify
      minifyDir = compiler.getMinifyDir()
      assetsRootDir = path.join(minifyDir, @config.assets.contextRoot)
      publicRootDir = path.join(minifyDir, @config.public.contextRoot)

      # JSおよびSourceMapが存在する
      js = fs.readFileSync(path.join(assetsRootDir, "main.js"), "utf-8")
      expect(js).to.eql(@mainMinJs)
      expect(fs.existsSync(path.join(assetsRootDir, "main.js.map"))).to.eql(true)

      # CSSおよびSourceMapが存在する
      css = fs.readFileSync(path.join(assetsRootDir, "main.css"), "utf-8")
      expect(css).to.eql(@mainMinCss)
      expect(fs.existsSync(path.join(assetsRootDir, "main.css.map"))).to.eql(true)

      # Publicのファイルが存在する
      html = fs.readFileSync(path.join(publicRootDir, "public.html"), "utf-8")
      expect(html).to.eql(@publicHtml)

      # ネストしたファイルが存在する
      expect(fs.existsSync(path.join(assetsRootDir, "nest", "main.js"))).to.eql(true)
      expect(fs.existsSync(path.join(publicRootDir, "nest", "nest.html"))).to.eql(true)




