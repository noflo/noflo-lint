manifest = require 'fbp-manifest'
component = require './component'
Promise = require 'bluebird'

exports.findDependencies = (baseDir, graph, options, callback) ->
  options.runtimes = ['noflo']
  options.recursive = true
  options.baseDir = baseDir
  manifest.dependencies.loadAndFind baseDir, graph, options, (err, deps) ->
    return callback err if err
    components = []
    graphs = []
    for module in deps
      for component in module.components
        collection = if component.elementary then components else graphs
        collection.push "#{module.name}/#{component.name}"
    callback null, components

exports.lint = (baseDir, graph, options, callback) ->
  finder = Promise.promisify exports.findDependencies
  lintComponent = Promise.promisify component.lint
  finder baseDir, graph, options
  .then (deps) ->
    Promise.map deps, (dep) ->
      lintComponent dep, options
  .nodeify callback

exports.main = main = ->
  program = require 'commander'
  .option('--manifest <manifest>', "Manifest file to use. Default is fbp.json", 'fbp.json')
  .arguments '<basedir> <graph>'
  .parse process.argv

  if program.args.length < 2
    program.args.unshift process.cwd()

  exports.lint program.args[0], program.args[1], program, (err, deps) ->
    if err
      console.error err
      process.exit 1
    console.log JSON.stringify deps, null, 2
    process.exit 0
