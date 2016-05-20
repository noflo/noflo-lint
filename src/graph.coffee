manifest = require 'fbp-manifest'
Promise = require 'bluebird'


exports.main = main = ->
  program = require 'commander'
  .option('--manifest <manifest>', "Manifest file to use. Default is fbp.json", 'fbp.json')
  .arguments '<basedir> <graph>'
  .parse process.argv

  if program.args.length < 2
    program.args.unshift process.cwd()

  program.recursive = true
  program.baseDir = program.args[0]
