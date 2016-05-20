exports.description = (instance, callback) ->
  unless instance.description
    return callback new Error "Missing description"
  callback null

exports.icon = (instance, callback) ->
  unless instance.icon
    return callback new Error "Missing icon"
  callback null
