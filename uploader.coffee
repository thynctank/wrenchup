wrench = require 'wrench'
fs = require 'fs'
chain = require 'chain-gang'

class Uploader
  #factory
  @getUploader: (opts) ->
    u = new Uploader opts
  #for now just assign basePath
  constructor: ({@basePath}) ->
    wrench.mkdirSyncRecursive(@basePath, 0777)
  #ensures subdir exists under @basePath, then moves file from fieldName to subdir
  #rewritten as middleware would not require req to be passed in
  put: (req, subdir, fields = [], cb) ->
    dirname = "#{@basePath}/#{subdir}"
    wrench.mkdirSyncRecursive dirname, 0777

    #allow single string passed in for one field
    fields = [fields] if !fields.indexOf

    for fieldName in fields
      chain.add (job) ->
        try
          timestamp = new Date().getTime()
          filename = "#{dirname}/#{timestamp}"
          origName = req.files[fieldName].path
          clientPath = "#{subdir}/#{timestamp}"

          fs.rename origName, filename
        catch error

    chain.on 'empty', ->
      cb(clientPath)
module.exports = Uploader
