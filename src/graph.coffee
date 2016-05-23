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

exports.analyze = (lintResults, rules, callback) ->
  results =
    components: []
    errors: 0
    warnings: 0
  for component in lintResults
    result =
      name: component.name
    for rule, failure of component.failed
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

  exports.lint program.args[0], program.args[1], program, (err, deps) ->
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

      for component in results.components
        color = colors.green
        if component.warn?.length
          color = colors.yellow
        if component.error?.length
          color = colors.red
        console.log ' ' + color component.name
        if component.error?.length
          for error in component.error
            console.log ' - ' + colors.red error
        if component.warn?.length
          for warning in component.warn
            console.log ' - ' + colors.yellow warning

      console.log " #{results.errors} errors, #{results.warnings} warnings"

      return process.exit 1 if results.errors > 0
      process.exit 0
