wrench = require 'wrench'
fs = require 'fs'
async = require 'async'

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

    clientPaths = []

    #setup enough workers for the number of fields
    q = async.queue (fieldName, cb2) ->
      field = req.files[fieldName]
      origName = field.name
      origPath = field.path
      filename = "#{dirname}/#{origName}"
      clientPaths.push "#{subdir}/#{origName}"

      fs.rename origPath, filename, cb2
    , fields.length
    
    #what happens when the queue is empty
    q.drain = ->
      cb(clientPaths)

    #queue up all the fields
    q.push fieldName for fieldName in fields
 
module.exports = Uploader
