exports.description = (instance, callback) ->
  unless instance.getDescription()
    return callback new Error "Missing description"
  callback null

exports.icon = (instance, callback) ->
  unless instance.getIcon()
    return callback new Error "Missing icon"
  callback null

exports.portDescriptions = (instance, callback) ->
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
