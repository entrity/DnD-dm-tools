require_relative './constants'
require_relative './encounter'
require_relative './roll'
require_relative './characters'
require_relative './treasure'
require 'forwardable'
require 'singleton'

class Game
  extend Forwardable
  include Singleton

  attr_reader    :cast, :console_histories, :encounters, :notes, :terrain
  attr_accessor  :encounter, :fpath

  def initialize fpath=nil
    @cast ||= [] # PCs and NPCs
    @console_histories ||= {} # History of console commands
    @encounter ||= Encounter.new # Current encounter
    @fpath ||= fpath
    @notes ||= []
    @terrain ||= nil
  end

  def load fpath
    if fpath && File.exists?(fpath)
      puts "Game loaded from #{fpath}"
      @fpath = fpath
      attrs = Marshal.load File.binread fpath
      attrs.each {|k,v| instance_variable_set(k,v) }
    end
  end

  # Save state to file
  def dump fpath=nil
    if fpath ||= @fpath
      attrs = instance_variables.map {|v| [v, instance_variable_get(v)] }.to_h
      File.binwrite fpath, Marshal.dump(attrs)
      puts "Saved to #{fpath}"
    end
  end
end
