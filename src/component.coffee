noflo = require 'noflo'
Promise = require 'bluebird'
checks = require './checks'
checkNames = Object.keys checks
checkers = Promise.promisifyAll checks
loaders = {}

getLoader = (baseDir) ->
  return loaders[baseDir] if loaders[baseDir]
  loaders[baseDir] = new noflo.ComponentLoader baseDir
  loaders[baseDir]

exports.load = (baseDir, component, callback) ->
  loader = getLoader baseDir
  loader.load component, callback

exports.lint = (component, options, callback) ->
  load = Promise.promisify exports.load
  load options.baseDir, component
  .then (instance) ->
    results =
      name: component
      passed: ['load']
      failed: {}

    Promise.map checkNames, (check) ->
      checkers["#{check}Async"] instance
      .then ->
        results.passed.push check
      .catch (failure) ->
        results.failed[check] = failure.message
    .then ->
      Promise.resolve results
  .catch (err) ->
    Promise.resolve results =
      name: component
      failed:
        load: err.message
  .nodeify callback
