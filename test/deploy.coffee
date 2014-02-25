should = require('should')
path = require('path')
{exec} = require('child_process')
{execCommand} = require('./util')
sneaky = path.join(__dirname, '../bin/sneaky')
local = process.env.local or ''
config = path.join(__dirname, "config#{local}.ini")
configHook = path.join(__dirname, "config-hooks#{local}.ini")
fs = require('fs')

describe 'command#deploy', ->

  @timeout(30000)

  before (done) ->
    execCommand 'git submodule init; git submodule update; rm -rf ~/.sneaky', done

  describe 'deploy:allprojects', ->
    it 'should deploy all projects from the config file', (done) ->
      execCommand "#{sneaky} deploy -c #{config}", (err, stdout, stderr) ->
        return done(err) if err?
        if stdout.indexOf('Finish deploy') < 0
          return done('deploy error')
        done()

  describe 'deploy:chosen', ->
    it 'will deploy two repositories in one action', (done) ->
      execCommand "#{sneaky} deploy -c #{config} async ini_a", (err, stdout, stderr) ->
        return done(err) if err?
        if stdout.indexOf('Finish deploy [async]') < 0 or
           stdout.indexOf('Finish deploy [ini_a]') < 0
          return done("deploy error")
        done()

  describe 'deploy:excludes', ->
    it 'will exclude [node_modules, tmp] in deployment', (done) ->
      execCommand "#{sneaky} deploy -c #{config} async", (err, stdout, stderr) ->
        return done(err) if err?
        if stdout.indexOf('--exclude=node_modules --exclude=tmp') < 0
          return done("deploy error")
        done()

  describe 'deploy:hooks', ->
    it 'will run hooks before/after rsync', (done) ->
      execCommand "#{sneaky} deploy -c #{configHook}", (err, stdout, stderr) ->
        return done(err) if err?
        if stdout.indexOf('LICENSE') < 0
          return done('deploy error')
        done()

  describe 'deploy:local', ->
    it 'will deploy with local configure file', (done) ->
      process.chdir(path.join(__dirname, './ini'))
      execCommand "cp ../config-ini.ini ./.sneakyrc && #{sneaky} deploy", (err, stdout, stderr) ->
        return done(err) if err?
        if stdout.indexOf('Finish deploy [ini_a]') < 0
          return done('deploy error')
        fs.unlink('./.sneakyrc', done)
