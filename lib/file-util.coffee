fs = require("fs")
path = require("path")

module.exports = class FileUtil

  @cleanSync: (src, deleteFolder=true) ->
    if fs.existsSync(src)
      files = fs.readdirSync(src)
      files.forEach (file) =>
        curSrc = "#{src}/#{file}"
        if fs.lstatSync(curSrc).isDirectory()
          @cleanSync(curSrc);
        else
          fs.unlinkSync(curSrc);
          console.log("delete #{curSrc}")

      if deleteFolder
        fs.rmdirSync(src);
        console.log("delete #{src}")

  @copySync: (src, dest) ->
    stats = fs.statSync(src)
    isDirectory = stats.isDirectory()
    if isDirectory
      fs.mkdirSync(dest)
      fs.readdirSync(src).forEach (file) =>
        @copySync(path.join(src, file), path.join(dest, file))
    else
      fs.linkSync(src, dest)

  @chownSync: (src, uid, gid) ->
    uid = 501
    gid = 20

    stats = fs.statSync(src)
    isDirectory = stats.isDirectory();
    if isDirectory
      fs.readdirSync(src).forEach (file) =>
        @chownSync(path.join(src, file), uid, gid)
        fs.chownSync(src, uid, gid)
    else
      console.log("chown: #{src}")
      fs.chownSync(src, uid, gid)
