#!/usr/bin/ruby

require 'json'
require 'set'
require 'singleton'
require_relative './abstract_library'
require_relative './constants'

class SpellLibrary < AbstractLibrary
  DATA_FILE_GLOB = 'open5e-spells*.json'
end
