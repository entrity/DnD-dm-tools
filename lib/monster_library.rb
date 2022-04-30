#!/usr/bin/ruby

require 'forwardable'
require 'json'
require 'set'
require 'singleton'
require_relative './constants'

class MonsterLibrary
  extend Forwardable
  include Singleton

  attr_accessor :environments
  def_delegators :@open5e_array, :length

  def initialize
    @open5e_array = []
    load_monsters
    load_environments
  end

  def [] name_or_idx
    if name_or_idx.is_a? Integer
      @open5e_array[name_or_idx]
    else
      @open5e_hash[name_or_idx.to_s] || @open5e_array.find {|v| v['slug'].downcase == name_or_idx.to_s.downcase }
    end
  end

  def for_environment name
    @environments[name.to_s.capitalize].map {|m| m.values_at('name', 'challenge_rating').join(' / ')}.sort
  end

  def has_key? key; @open5e_hash.has_key? key; end

  def inspect; "<MonsterLibrary:#{object_id} @length=#{length}>"; end

  def list; @open5e_array; end

  def method_missing name, *args, **kwargs
    if terrain = @environments.keys.find { |k| k.downcase == name.downcase }
      @environments[terrain]
    else
      super
    end
  end

  # Return name + CR
  def print
    @open5e_array.map do |mon|
      "#{mon['name']} (CR #{mon['challenge_rating']})"
    end
  end

  def sample opts={}
    if terrain = opts[:terrain]
      selection = @environments[terrain]
      selection += @environments['Any'] unless opts[:strict]
    else
      selection = @open5e_array.dup
    end
    if cr = opts[:cr]
      cr = eval("#{cr}.0") if cr.is_a?(String)
      selection = selection.select {|mon| MonsterLibrary.cr(mon) == cr }
    end
    selection.sample
  end

  def self.cr monster_attrs
    eval("#{monster_attrs['challenge_rating']}.0")
  end

  def self.sample *args
    MonsterLibrary.instance.sample *args
  end

  private

  def load_environments
    # Apply environment data from https://donjon.bin.sh/5e/monsters/
    donjon_monsters = JSON.parse(File.read File.join DATA_DIR, 'donjon.bin-monsters.json')
    @environments = { 'Any' => SortedSet.new }
    @open5e_hash.each do |name, monster|
      if environment_hash = donjon_monsters.dig(name, 'environment')
        environment_hash.keys.each { |key|
          @environments[key] ||= SortedSet.new
          @environments[key] << monster
        }
      else
        @environments['Any'] << monster
      end
    end
  end

  def load_monsters
    # Get monsters from https://api.open5e.com/ files
    @open5e_array = Dir[File.join DATA_DIR, 'open5e-monsters*'].reduce([]) do |acc, fpath|
      results = JSON.parse(File.read fpath)['results']
      acc + results.map {|h| Item.new(h) }
    end
    Dir[File.join DATA_DIR, 'npc-statblock-compendium', '*.json'].each do |fpath|
      parsed = JSON.parse(File.read fpath)
      @open5e_array << Item.new(parsed)
    end
    @open5e_hash = @open5e_array.map {|m| [m['name'], m]}.to_h
  end

  class Item < OpenStruct
    def <=> other
      compare_crs = cr_float <=> other.cr_float
      compare_crs.zero? ? self['slug'] <=> other['slug'] : compare_crs
    end

    def cr_float
      eval "%s.0" % self['challenge_rating']
    end
  end
end
