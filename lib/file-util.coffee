fs = require("fs")
path = require("path")

module.exports = class FileUtil

  @clean: (path, deleteFolder=true) ->
    if fs.existsSync(path)
      files = fs.readdirSync(path)
      files.forEach (file) =>
        curPath = "#{path}/#{file}"
        if fs.lstatSync(curPath).isDirectory()
          @clean(curPath);
        else
          fs.unlinkSync(curPath);
          console.log("delete #{curPath}")

      if deleteFolder
        fs.rmdirSync(path);
        console.log("delete #{path}")

  @copy: (src, dest) ->
    exists = fs.existsSync(src);
    stats = exists && fs.statSync(src);
    isDirectory = exists && stats.isDirectory();
    if exists && isDirectory
      fs.mkdirSync(dest)
      fs.readdirSync(src).forEach (file) =>
        @copy(path.join(src, file), path.join(dest, file))
    else
      fs.linkSync(src, dest)
