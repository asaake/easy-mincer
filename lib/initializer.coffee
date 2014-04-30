Mincer = require "mincer"

Mincer.CoffeeEngine.configure({bare: false})

RequireEngine = require "./engines/require-engine"
Mincer.registerEngine(".amd", RequireEngine)