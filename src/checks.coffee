exports.description = (instance, callback) ->
  unless instance.getDescription()
    return callback new Error "Missing description"
  callback null

exports.icon = (instance, callback) ->
  unless instance.getIcon()
    return callback new Error "Missing icon"
  callback null

exports.port_descriptions = (instance, callback) ->
  missing = []
  for name, def of instance.inPorts.ports
    continue if def.getDescription()
    missing.push name
  for name, def of instance.outPorts.ports
    continue if def.getDescription()
    missing.push name
  if missing.length
    return callback new Error "Missing port descriptions: #{missing.join(', ')}"
  callback null

exports.wirepattern = (instance, callback) ->
  unless typeof instance.groupedData is 'object'
    return callback new Error "Not using WirePattern"
  callback null

exports.process_api = (instance, callback) ->
  unless typeof instance.handle is 'function'
    return callback new Error "Not using Process API"
  callback null

exports.asynccomponent = (instance, callback) ->
  if typeof instance.doAsync is 'function'
    return callback new Error "Using AsyncComponent API"
  callback null

exports.legacy_api = (instance, callback) ->
  exports.processApi instance, (err) ->
    return callback null unless err
    exports.wirePattern instance, (err) ->
      return callback null unless err
      callback new Error "Using legacy API"
