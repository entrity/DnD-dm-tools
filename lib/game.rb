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

  def self.load fpath=nil
    if fpath
      Marshal.load File.read(fpath).tap {|game| game.fpath = fpath }
    else
      new
    end
  end

  def initialize fpath=nil
    @cast = [] # PCs and NPCs
    @console_histories = {} # History of console commands
    @encounter = Encounter.new # Current encounter
    @encounters = [] # Array of Encounter
    @fpath = fpath
    @notes = []
    @terrain = nil
  end

  # CRs for current party for all difficulties
  def crs_for_party
    Encounter.crs_for_party(@party)
  end

  # Save state to file
  def dump
    File.write @fpath, Marshal.dump(self)
    puts "Saved to #{@fpath}"
  end

  # Start a random encounter
  def encounter difficulty, terrain=nil
    terrain ||= @terrain
    $encounter = Encounter.random @party, difficulty, terrain
  end

  def increment_fpath
    if File.exists?(@fpath)
      split = @fpath.match(/(.*?)(\d+$)/)
      stem = split&.[](1) || @fpath
      number = 1 + split&.[](2).to_i
      @fpath = "#{stem}#{number}"
    end
  end

  def monsters *fields, **search
    selection = $monsters.list
    sort_key = search.delete(:sort)&.to_s
    unless search.empty?
      selection = selection.select {|m| search.all? {|k,v| m[k.to_s] == v } }
    end
    unless sort_key.nil?
      selection = selection.sort {|a,b|
        va, vb = [a,b].map { |x|
          # Handle CR, which is stored as a string, e.g. "1/8"
          x[sort_key].to_s =~ /^\d$|^\d.*\d$/ ? eval(x[sort_key]) : x[sort_key]
        }
        va <=> vb
      }
    end
    unless fields.empty?
      selection = selection.map {|m| m.values_at *fields.map(&:to_s) }
    end
    selection
  end
end
