#!/usr/bin/ruby

require 'json'
require 'set'
require 'singleton'
require_relative './constants'

class MonsterLibrary
  include Singleton

  def initialize
    @open5e_array = []
    load_monsters
    # load_environments
  end

  def [] name_or_idx
    if name_or_idx.is_a? Integer
      @open5e_array[name_or_idx]
    else
      @open5e_hash[name_or_idx] || @open5e_array.find {|v| v['slug'].downcase == name_or_idx.downcase }
    end
  end

  def for_environment name
    @environments[name.to_s.capitalize].map {|m| m.values_at('name', 'challenge_rating').join(' / ')}.sort
  end

  def has_key? key; @open5e_hash.has_key? key; end

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
      selection += @environments['any'] unless opts[:strict]
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
    @library ||= MonsterLibrary.new
    @library.sample *args
  end

  private

  def load_environments
    # Apply environment data from https://donjon.bin.sh/5e/monsters/
    donjon_monsters = JSON.parse(File.read File.join DATA_DIR, 'donjon.bin-monsters.json')
    @environments = {'any' => Set.new}
    @open5e_hash.each do |name, monster|
      if donjon_data = donjon_monsters[name]
        if environment_hash = donjon_data['environment']
          environment_hash.keys.each do |key|
            @environments[key] ||= Set.new
            @environments[key] << monster
          end
        else
          @environments['any'] << monster
        end
      else
        @environments['any'] << monster
      end
    end
  end

  def load_monsters
    # Get monsters from https://api.open5e.com/ files
    @open5e_array = Dir[File.join DATA_DIR, 'open5e-monsters*'].reduce([]) do |acc, fpath|
      results = JSON.parse(File.read fpath)['results']
      acc + results
    end
    @open5e_hash = @open5e_array.map {|m| [m['name'], m]}.to_h
  end
end
