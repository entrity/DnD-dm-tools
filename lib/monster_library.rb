#!/usr/bin/ruby

require 'json'
require 'set'

class MonsterLibrary
  def initialize
    load_monsters
    load_environments
  end

  def [] name
    @open5e_hash[name]
  end

  def sample terrain=nil, strict=false
    if terrain.nil?
      @open5e_array.sample
    elsif strict
      @environments[terrain].sample
    else
      population = @environments[terrain] + @environments['any']
      population.sample
    end
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
      results.each { |m| m['challenge_rating'] = m['challenge_rating'].to_f }
      acc + results
    end
    @open5e_hash = @open5e_array.map {|m| [m['name'], m]}.to_h
  end
end

$monsters = MonsterLibrary.new
