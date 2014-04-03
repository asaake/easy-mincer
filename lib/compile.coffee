Mincer = require("mincer")
fs = require("fs")
config = require("./config.coffee")
environment = config.environment

file = {
  main: config.main
  dest: config.dest
  mainDir: config.cwd
  destDir: config.cwd + "/dest"
  manifestDir: config.cwd + "/manifest"
}

# clean
deleteFolderRecursive = (path, deleteFolder=true) ->
  files = [];
  if fs.existsSync(path)
    files = fs.readdirSync(path);
    files.forEach (file,index) ->
      curPath = path + "/" + file;
      if fs.lstatSync(curPath).isDirectory()
        deleteFolderRecursive(curPath);
      else
        fs.unlinkSync(curPath);
        console.log("delete #{curPath}")

    if deleteFolder
      fs.rmdirSync(path);
      console.log("delete #{path}")

deleteFolderRecursive(file.destDir, false)
deleteFolderRecursive(file.manifestDir, false)

manifest = new Mincer.Manifest(environment, file.manifestDir)
try
  assetsData = manifest.compile([file.main], {
    compress: true,
    sourceMaps: true,
    embedMappingComments: true
  });

  console.info('\n\nAssets were successfully compiled.\n' +
    'Manifest data (a proper JSON) was written to:\n' +
    manifest.path + '\n\n');
  console.dir(assetsData);
catch err
  console.error("Failed compile assets: " + (err.message || err.toString()));

readFile = assetsData.assets[file.main]
if readFile?
  writeFile = "#{file.destDir}/#{file.dest}"
  readFile = "#{file.manifestDir}/#{readFile}"
  fs = require("fs")
  fs.writeFileSync(writeFile, fs.readFileSync(readFile))
  console.info("create #{writeFile}")

