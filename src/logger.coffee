colors = require('colors')
fs = require('fs')
mkdirp = require('mkdirp')
Moment = require('moment')

class Logger

  constructor: (logFile = null, writeOptions = null, readOptions = null) ->
    moment = new Moment()
    @logPath = "#{process.env.HOME}/.sneaky/logs"
    @logFile = logFile or "#{@logPath}/#{moment.format('YYYY-MM-DD')}.log"
    @writeOptions = writeOptions or {flag: 'a'}
    @readOptions = readOptions or {encoding: 'utf8'}
    @prefix =
      log: ''
      err: ''
      warn: ''
    mkdirp.sync(@logPath)

  setPrefix: (prefix) ->
    for type, string of prefix
      @prefix[type] = string

  expandPath: (uPath) ->
    if matches = uPath.match(/^~(.*)/)  # home path
      return "#{process.env.HOME}#{matches[1]}"
    return uPath

  _log: (color, str) =>
    console.log(str[color])
    fs.writeFile(@logFile, "#{str}\n", @writeOptions)

  background: ->
    @log.log("progress is now running in background, you can checkout the log in #{logFile}.mess")
    fs.writeFile(@logFile, "#{(v for i, v of arguments).join(' ')}\n", {flag: 'a'})

  log: ->
    @_log.apply(this, ['grey', "#{@prefix['log']}" + (v for i, v of arguments).join(' ')])

  warn: ->
    @_log.apply(this, ['yellow', "#{@prefix['warn']}" + (v for i, v of arguments).join(' ')])

  err: ->
    @_log.apply(this, ['red', "#{@prefix['err']}" + (v for i, v of arguments).join(' ')])

  readFile: (callback = ->) ->
    fs.readFile(@logFile, @readOptions, callback)

  readFileSync: ->
    return fs.readFileSync(@logFile, @readOptions)

module.exports = Logger