manifest = require 'fbp-manifest'
component = require './component'
Promise = require 'bluebird'

defaults =
  description: 'warn'
  icon: 'ignore'
  port_descriptions: 'ignore'
  wirepattern: 'warn'
  process_api: 'warn'
  asynccomponent: 'error'
  legacy_api: 'error'

exports.findDependencies = (baseDir, graph, options, modules, callback) ->
  options.runtimes = ['noflo'] unless options.runtimes
  options.recursive = true
  options.baseDir = baseDir unless options.baseDir
  manifest.dependencies.find modules, graph, options, (err, deps) ->
    return callback err if err
    components = []
    graphs = []
    for module in deps
      for comp in module.components
        collection = if comp.elementary then components else graphs
        collection.push "#{module.name}/#{comp.name}"
    callback null, components

exports.loadAndLint = (baseDir, graph, options, callback) ->
  options.runtimes = ['noflo']
  options.recursive = true
  options.baseDir = baseDir
  loader = Promise.promisify manifest.load.load
  linter = Promise.promisify exports.lint
  loader baseDir, options
  .then (manifest) ->
    linter baseDir, graph, options, manifest.modules
  .nodeify callback

exports.lint = (baseDir, graph, options, modules, callback) ->
  finder = Promise.promisify exports.findDependencies
  lintComponent = Promise.promisify component.lint
  finder baseDir, graph, options, modules
  .then (deps) ->
    Promise.map deps, (dep) ->
      lintComponent dep, options
  .nodeify callback

exports.analyze = (lintResults, rules, callback) ->
  results =
    components: []
    errors: 0
    warnings: 0
  for comp in lintResults
    result =
      name: comp.name
    for rule, failure of comp.failed
      continue if rules[rule] is 'ignore'
      if rules[rule] is 'warn'
        result.warn = [] unless result.warn
        result.warn.push failure
        results.warnings++
      if rules[rule] is 'error'
        result.error = [] unless result.error
        result.error.push failure
        results.errors++
    results.components.push result

  callback null, results

exports.main = main = ->
  program = require 'commander'
  .option('--manifest <manifest>', "Manifest file to use. Default is fbp.json", 'fbp.json')
  .option('--json', "Whether to output raw JSON results", false)
  .arguments '<basedir> <graph>'
  .parse process.argv

  if program.args.length < 2
    program.args.unshift process.cwd()

  exports.loadAndLint program.args[0], program.args[1], program, (err, deps) ->
    if err
      console.error err
      process.exit 1
    if program.json
      console.log JSON.stringify deps, null, 2
      process.exit 0
    colors = require 'colors-cli'
    exports.analyze deps, defaults, (err, results) ->
      if err
        console.error err
        process exit 1

      console.log "#{program.args[1]} dependencies:"

      for comp in results.components
        color = colors.green
        if comp.warn?.length
          color = colors.yellow
        if comp.error?.length
          color = colors.red
        console.log ' ' + color comp.name
        if comp.error?.length
          for error in comp.error
            console.log ' - ' + colors.red error
        if comp.warn?.length
          for warning in comp.warn
            console.log ' - ' + colors.yellow warning

      console.log " #{results.errors} errors, #{results.warnings} warnings"

      return process.exit 1 if results.errors > 0
      process.exit 0
