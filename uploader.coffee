wrench = require 'wrench'
fs = require 'fs'

class Uploader
  #factory
  @getUploader: (opts) ->
    u = new Uploader opts
  #for now just assign basePath
  constructor: ({@basePath}) ->
    wrench.mkdirSyncRecursive(@basePath, 0777)
  #ensures subdir exists under @basePath, then moves file from fieldName to subdir
  #rewritten as middleware would not require req to be passed in
  put: (req, subdir, fieldName, cb) ->
    dirname = "#{@basePath}/#{subdir}"
    timestamp = new Date().getTime()
    filename = "#{dirname}/#{timestamp}"
    origName = req.files[fieldName].path

    wrench.mkdirSyncRecursive dirname, 0777
    fs.rename origName, filename, cb

module.exports = Uploader
