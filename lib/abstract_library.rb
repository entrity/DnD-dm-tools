#!/usr/bin/ruby

require 'json'
require 'set'
require 'singleton'
require_relative './constants'

class AbstractLibrary
  include Singleton
  extend Forwardable

  attr_reader :list
  def_delegators :list, :has_key?

  def initialize
    @list = []
    @dict = {}
    load
  end

  def [] name_or_idx
    if name_or_idx.is_a? Integer
      @open5e_array[name_or_idx]
    else
      @open5e_hash[name_or_idx] || @open5e_array.find {|v| v['slug'].downcase == name_or_idx.downcase }
    end
  end

  def method_missing name, *args, **kwargs
    if terrain = @environments.keys.find { |k| k.downcase == name.downcase }
      @environments[terrain]
    else
      super
    end
  end

  private

  # Get data from https://api.open5e.com/ files
  def load
    @list = Dir[File.join DATA_DIR, self.class::DATA_FILE_GLOB].reduce([]) do |acc, fpath|
      results = JSON.parse(File.read fpath)['results']
      acc + results
    end
    @dict = list.map {|m| [m['name'], m]}.to_h
  end
end
