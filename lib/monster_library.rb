#!/usr/bin/ruby

require 'json'
require 'set'

class MonsterLibrary
  def initialize
    load_monsters
    load_environments
  end

  def [] name_or_idx
    if name_or_idx.is_a? Fixnum
      @open5e_array[name_or_idx]
    else
      @open5e_hash[name_or_idx]
    end
  end

  def list; @open5e_array; end

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
    donjon_monsters = JSON.parse(File.read 'data/donjon.bin-monsters.json')
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
    @open5e_array = Dir['data/open5e-monsters*'].reduce([]) do |acc, fpath|
      results = JSON.parse(File.read fpath)['results']
      acc + results
    end
    @open5e_hash = @open5e_array.map {|m| [m['name'], m]}.to_h
  end
end

$monsters = MonsterLibrary.new
