#!/usr/bin/env ruby

Dir.chdir File.dirname(__FILE__)

require 'json'
require 'optparse'
require 'pry'
require './lib/game'
require './ui/main'

opts = {}
OptionParser.new do |o|
  o.banner = "Usage: cmd [-c] <savfile>"
  o.on('-c', '--cli', "No gui") { opts[:cli] = true }
end.parse!

if File.realpath($0) == File.realpath(__FILE__)
  Game.instance.load ARGV[0]
  if opts[:cli]
    binding.pry Game.instance
  else
    MainUI.instance.run
  end
end

