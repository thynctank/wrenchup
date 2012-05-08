wrench = require 'wrench'
fs = require 'fs'
chainGang = require 'chain-gang'

chain = chainGang.create workers: 3

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
    fields = [fields] if not Array.isArray(fields)

    cb("no fields") if fields.length < 1

    clientPaths = []

    for fieldName in fields
      fields.splice fields.indexOf(fieldName), 1
      chain.add (job) ->
        try
          timestamp = new Date().getTime()
          filename = "#{dirname}/#{timestamp}"
          origName = req.files[fieldName].path
          clientPaths.push "#{subdir}/#{timestamp}"

          fs.rename origName, filename, ->
            cb(null, clientPaths) if fields.length is 0
            job.finish()
        catch error

module.exports = Uploader
