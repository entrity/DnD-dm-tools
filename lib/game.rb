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
    @encounters ||= [] # Array of Encounter
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

  # CRs for current party for all difficulties
  def crs_for_party
    Encounter.crs_for_party(@party)
  end

  # Save state to file
  def dump fpath=nil
    if fpath ||= @fpath
      attrs = instance_variables.map {|v| [v, instance_variable_get(v)] }.to_h
      File.binwrite fpath, Marshal.dump(attrs)
      puts "Saved to #{fpath}"
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
