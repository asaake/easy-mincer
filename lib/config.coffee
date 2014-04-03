Mincer = require("mincer")
path = require("path")

index = process.argv.indexOf("--easy-mincer-dir")
dir = "#{process.cwd()}"
if index != -1
  dir = path.resolve(process.argv[index + 1])
file = "#{dir}/easy-mincer.json"

console.log("easy-mincer-config: #{file}")
config = require(file)
environment = new Mincer.Environment(dir)
targets = config.paths
for target in targets
  environment.appendPath(target);
  console.log("appendPath:[#{target}]")

config.cwd = dir
config.environment = environment
module.exports = config