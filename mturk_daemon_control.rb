#!/usr/local/bin/ruby
require 'rubygems'
require 'daemons'

Daemons.run("mturk_daemon.rb")
