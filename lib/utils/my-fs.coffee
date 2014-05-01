require("coffee-script")

fs = require("fs-extra")
path = require("path")

fs.cleanSync = (src, deleteFolder=true) ->
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

fs.chownRSync = (src, uid, gid) ->
  uid = 501
  gid = 20

  stats = fs.statSync(src)
  isDirectory = stats.isDirectory();
  if isDirectory
    fs.readdirSync(src).forEach (file) =>
      fs.chownRSync(path.join(src, file), uid, gid)
      fs.chownSync(src, uid, gid)
  else
    console.log("chown: #{src}")
    fs.chownSync(src, uid, gid)

module.exports = fs
