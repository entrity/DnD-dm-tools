require_relative './constants'
require_relative './encounter'
require_relative './roll'
require_relative './treasure'
require_relative './character/pc'
require 'forwardable'
require 'singleton'

THIS_DIR = File.dirname(__FILE__)
LAST_DATA_PATH = File.join(File.dirname(THIS_DIR), '.last-load')

class Game
  extend Forwardable
  include Singleton

  attr_reader    :cast, :console_histories, :encounters, :notes, :terrain
  attr_accessor  :char, :encounter, :fpath

  def initialize
    @cast ||= [] # PCs and NPCs
    @console_histories ||= {} # History of console commands
    @encounter ||= Encounter.new # Current encounter
    @encounters = []
    @fpath = nil
    @notes ||= []
    @terrain ||= nil
  end

  def load fpath
    if fpath.nil?
      load_last_game
    elsif File.exists?(fpath)
      puts "Game loading from #{fpath}"
      attrs = Marshal.load File.binread fpath
      attrs.each {|k,v| instance_variable_set(k,v) }
      @fpath = fpath
      File.write LAST_DATA_PATH, fpath
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

  def add_pc name, level
    @cast << ::Pc.new(name, level)
  end

  def pc name
    @cast.find {|c| c.name.to_s.downcase.strip == name.to_s.downcase.strip }
  end

  def pcs
    @cast.select {|c| c.is_pc }
  end

  def npcs
    @cast.select {|c| !c.is_pc }
  end

  private

  def load_last_game
    puts "Trying to load last game. Looking for #{LAST_DATA_PATH}"
    if File.exists? LAST_DATA_PATH
      game_path = File.read(LAST_DATA_PATH).gsub(/[\r\n]/, '')
      puts "Found #{game_path} in #{LAST_DATA_PATH}"
      if File.exists? game_path
        load game_path
      end
    end
  end
end
