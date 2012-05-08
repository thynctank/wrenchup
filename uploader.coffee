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
    fields = [fields] if !fields.indexOf

    cb("no fields") if !fields.length

    clientPaths = []

    for fieldName in fields
      chain.add (job) ->
        try
          timestamp = new Date().getTime()
          filename = "#{dirname}/#{timestamp}"
          origName = req.files[fieldName].path
          clientPaths.push "#{subdir}/#{timestamp}"

          fs.rename origName, filename
        catch error

    chain.on 'empty', ->
      cb(null, clientPaths)
module.exports = Uploader
